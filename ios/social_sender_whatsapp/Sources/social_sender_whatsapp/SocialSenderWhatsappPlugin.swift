import Flutter
import UIKit

public class SocialSenderWhatsappPlugin: NSObject, FlutterPlugin, UIDocumentInteractionControllerDelegate {
    private let whatsappScheme = "whatsapp://"
    private let whatsappBusinessScheme = "whatsapp-business://"
    private var tempFileUrls: [URL] = []
    private var documentController: UIDocumentInteractionController?
    private var pendingResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "social_sender_whatsapp", binaryMessenger: registrar.messenger())
        let instance = SocialSenderWhatsappPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "send":
            share(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func share(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        let text = args["text"] as? String
        let phone = args["phone"] as? String
        let files = args["files"] as? [String]

        // 1. If we have files - use UIDocumentInteractionController with WhatsApp UTI
        if let files = files, !files.isEmpty {
            shareFilesExclusively(filePaths: files, text: text, result: result)
            return
        }

        // 2. If we have phone + text or just phone
        if let phone = phone, !phone.isEmpty {
            shareViaWaMe(phone: phone, text: text, result: result)
            return
        }

        // 3. If we have just text
        if let text = text, !text.isEmpty {
            shareTextDirectly(text: text, result: result)
            return
        }

        // 4. Fallback: Just open WhatsApp
        openWhatsApp(result: result)
    }

    private func shareFilesExclusively(filePaths: [String], text: String?, result: @escaping FlutterResult) {
        cleanupTempFiles()

        // UIDocumentInteractionController only supports a single file.
        // We use the first file for sharing. For multiple files, WhatsApp on iOS
        // handles them as individual messages anyway.
        guard let firstFilePath = filePaths.first else {
            result(FlutterError(code: "FILE_ERROR", message: "No files provided", details: nil))
            return
        }

        let originalUrl = URL(fileURLWithPath: firstFilePath)
        let fileExtension = originalUrl.pathExtension.lowercased()

        // Determine the WhatsApp-specific UTI and file extension
        let waExtension: String
        let waUTI: String
        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "webp", "heic":
            waExtension = "wai"
            waUTI = "net.whatsapp.image"
        case "mp4", "mov", "avi", "mkv", "3gp":
            waExtension = "wam"
            waUTI = "net.whatsapp.movie"
        case "mp3", "aac", "m4a", "ogg", "opus", "wav":
            waExtension = "waa"
            waUTI = "net.whatsapp.audio"
        default:
            waExtension = "wai"
            waUTI = "net.whatsapp.image"
        }

        // Create a temporary copy with the WhatsApp-specific extension
        let fileName = originalUrl.deletingPathExtension().lastPathComponent
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
            .appendingPathExtension(waExtension)

        do {
            if FileManager.default.fileExists(atPath: tempUrl.path) {
                try FileManager.default.removeItem(at: tempUrl)
            }
            try FileManager.default.copyItem(at: originalUrl, to: tempUrl)
            self.tempFileUrls.append(tempUrl)
        } catch {
            result(FlutterError(code: "FILE_ERROR", message: "Could not prepare file for WhatsApp", details: error.localizedDescription))
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Create UIDocumentInteractionController with WhatsApp-specific UTI
            let docController = UIDocumentInteractionController(url: tempUrl)
            docController.uti = waUTI
            docController.delegate = self

            // Keep a strong reference so it doesn't get deallocated
            self.documentController = docController
            self.pendingResult = result

            // Find the root view controller to present from
            guard let viewController = self.findRootViewController() else {
                result(FlutterError(code: "UI_ERROR", message: "Could not find root view controller", details: nil))
                return
            }

            // presentOpenInMenu shows ONLY apps that can handle this UTI
            // For net.whatsapp.* UTIs, this means only WhatsApp and WhatsApp Business
            let presented = docController.presentOpenInMenu(
                from: viewController.view.bounds,
                in: viewController.view,
                animated: true
            )

            if !presented {
                // No apps can handle this UTI - WhatsApp is likely not installed
                self.pendingResult = nil
                self.documentController = nil
                result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "WhatsApp is not installed!", details: nil))
            }
        }
    }

    // MARK: - UIDocumentInteractionControllerDelegate

    public func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        // User dismissed the menu (tapped outside / cancelled)
        if let pendingResult = self.pendingResult {
            pendingResult(true)
        }
        self.pendingResult = nil
        self.documentController = nil
    }

    public func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        // User selected an app - the file will be sent
        if let pendingResult = self.pendingResult {
            pendingResult(true)
        }
        self.pendingResult = nil
    }

    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return findRootViewController() ?? UIViewController()
    }

    // MARK: - Helper to find root view controller

    private func findRootViewController() -> UIViewController? {
        if #available(iOS 15.0, *) {
            // Use the modern scene-based approach
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first
            if let rootVC = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                return rootVC
            }
        }
        // Fallback for older iOS versions
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }

    private func shareViaWaMe(phone: String, text: String?, result: @escaping FlutterResult) {
        let sanitizedPhone = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var urlString = "https://wa.me/\(sanitizedPhone)"

        if let text = text, let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "?text=\(encodedText)"
        }

        guard let url = URL(string: urlString) else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid URL", details: nil))
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                result(true)
            } else {
                self.shareTextDirectly(text: text ?? "", phone: sanitizedPhone, result: result)
            }
        }
    }

    private func shareTextDirectly(text: String, phone: String? = nil, result: @escaping FlutterResult) {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var query = "text=\(encodedText)"
        if let phone = phone {
            query += "&phone=\(phone)"
        }

        let whatsappUrl = URL(string: "whatsapp://send?\(query)")
        let businessUrl = URL(string: "whatsapp-business://send?\(query)")

        if let url = whatsappUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in result(true) }
            return
        }

        if let url = businessUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in result(true) }
            return
        }

        if let url = whatsappUrl {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    result(true)
                } else if let bUrl = businessUrl {
                    UIApplication.shared.open(bUrl, options: [:]) { successBusiness in
                        if successBusiness {
                            result(true)
                        } else {
                            result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "Whatsapp not installed!", details: nil))
                        }
                    }
                } else {
                    result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "Whatsapp not installed!", details: nil))
                }
            }
        }
    }

    private func openWhatsApp(result: @escaping FlutterResult) {
        let whatsappUrl = URL(string: "whatsapp://app")
        let businessUrl = URL(string: "whatsapp-business://app")

        if let url = whatsappUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in result(true) }
        } else if let url = businessUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { _ in result(true) }
        } else {
            UIApplication.shared.open(whatsappUrl!, options: [:]) { success in
                if success {
                    result(true)
                } else {
                    result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "Whatsapp not installed!", details: nil))
                }
            }
        }
    }

    private func cleanupTempFiles() {
        for url in tempFileUrls {
            try? FileManager.default.removeItem(at: url)
        }
        tempFileUrls.removeAll()
    }
}
