import Flutter
import UIKit

public class SocialSenderWhatsappPlugin: NSObject, FlutterPlugin {
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

    if let files = files, !files.isEmpty {
      shareFiles(files: files, text: text, result: result)
    } else if let phone = phone, !phone.isEmpty {
      shareViaUrl(phone: phone, text: text, result: result)
    } else if let text = text, !text.isEmpty {
        // Just text, no phone, no files
        shareFiles(files: [], text: text, result: result)
    } else {
        // Fallback open WhatsApp
        openWhatsApp(result: result)
    }
  }

  private func shareViaUrl(phone: String, text: String?, result: @escaping FlutterResult) {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "wa.me"
    components.path = "/\(phone)"

    var queryItems = [URLQueryItem]()
    if let text = text {
      queryItems.append(URLQueryItem(name: "text", value: text))
    }
    components.queryItems = queryItems

    guard let url = components.url else {
      result(FlutterError(code: "INVALID_URL", message: "Invalid URL", details: nil))
      return
    }

    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
      result(true)
    } else {
      result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "Whatsapp not installed!", details: nil))
    }
  }

  private func shareFiles(files: [String], text: String?, result: @escaping FlutterResult) {
    var activityItems: [Any] = []
    
    if let text = text {
      activityItems.append(text)
    }
    
    for filePath in files {
      let fileUrl = URL(fileURLWithPath: filePath)
      activityItems.append(fileUrl)
    }
    
    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    
    // On iPad, UIActivityViewController needs a source view or bar button item
    if let popover = activityViewController.popoverPresentationController {
      if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
         let rootVC = window.rootViewController {
        popover.sourceView = rootVC.view
        popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
      }
    }

    DispatchQueue.main.async {
      if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
         let rootVC = window.rootViewController {
        rootVC.present(activityViewController, animated: true, completion: nil)
        result(true)
      } else {
        result(FlutterError(code: "UI_ERROR", message: "Could not find root view controller", details: nil))
      }
    }
  }
    
  private func openWhatsApp(result: @escaping FlutterResult) {
      if let url = URL(string: "whatsapp://app") {
          if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
              result(true)
          } else {
              result(FlutterError(code: "WHATSAPP_NOT_INSTALLED", message: "Whatsapp not installed!", details: nil))
          }
      } else {
          result(false)
      }
  }
}
