package com.chegz.social_sender_whatsapp

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.net.URLConnection

/** SocialSenderWhatsappPlugin */
class SocialSenderWhatsappPlugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "social_sender_whatsapp")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        if (call.method == "send") {
            send(call, result)
        } else {
            result.notImplemented()
        }
    }

    private fun send(call: MethodCall, result: Result) {
        val text = call.argument<String>("text")
        val phone = call.argument<String>("phone")
        val files = call.argument<List<String>>("files")

        val isWhatsappInstalled = isAppInstalled("com.whatsapp")
        val isBussinessWhatsappInstalled = isAppInstalled("com.whatsapp.w4b")

        if (!isWhatsappInstalled && !isBussinessWhatsappInstalled) {
            Log.e("WHATSAPP_NOT_INSTALLED", "Whatsapp not installed!")
            result.error("WHATSAPP_NOT_INSTALLED", "Whatsapp not installed!", null)
            return
        }

        if (files != null && files.isNotEmpty()) {
            shareFiles(phone, text, files, isWhatsappInstalled, isBussinessWhatsappInstalled, result)
        } else {
            shareText(phone, text, isWhatsappInstalled, isBussinessWhatsappInstalled, result)
        }
    }

    private fun shareText(
        phone: String?,
        text: String?,
        isWhatsappInstalled: Boolean,
        isBusinessInstalled: Boolean,
        result: Result
    ) {
        val whatsappIntents = mutableListOf<Intent>()

        if (phone != null && phone.isNotEmpty()) {
            if (isWhatsappInstalled) {
                whatsappIntents.add(
                    Intent(Intent.ACTION_VIEW).apply {
                        flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                        data = Uri.parse("https://wa.me/$phone?text=${Uri.encode(text ?: "")}")
                        `package` = "com.whatsapp"
                    }
                )
            }
            if (isBusinessInstalled) {
                whatsappIntents.add(
                    Intent(Intent.ACTION_VIEW).apply {
                        flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                        data = Uri.parse("https://wa.me/$phone?text=${Uri.encode(text ?: "")}")
                        `package` = "com.whatsapp.w4b"
                    }
                )
            }
        } else {
            // No phone number, open WhatsApp chooser
            if (isWhatsappInstalled) {
                whatsappIntents.add(
                    Intent(Intent.ACTION_SEND).apply {
                        flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                        type = "text/plain"
                        if (text != null && text.isNotEmpty()) {
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        `package` = "com.whatsapp"
                    }
                )
            }
            if (isBusinessInstalled) {
                whatsappIntents.add(
                    Intent(Intent.ACTION_SEND).apply {
                        flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                        type = "text/plain"
                        if (text != null && text.isNotEmpty()) {
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        `package` = "com.whatsapp.w4b"
                    }
                )
            }
        }

        startChooser(whatsappIntents, result)
    }

    private fun shareFiles(
        phone: String?,
        text: String?,
        files: List<String>,
        isWhatsappInstalled: Boolean,
        isBusinessInstalled: Boolean,
        result: Result
    ) {
        val uris = ArrayList<Uri>()
        val mimeTypes = mutableSetOf<String>()
        
        try {
            for (filePath in files) {
                val file = File(filePath)
                val uri = FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
                uris.add(uri)
                
                val guessedMime = URLConnection.guessContentTypeFromName(file.name) ?: "*/*"
                mimeTypes.add(guessedMime.split("/")[0])
            }
        } catch (e: Exception) {
            result.error("FILE_NOT_FOUND", "Error getting URI for file: ${e.message}", null)
            return
        }

        val action = if (uris.size > 1) Intent.ACTION_SEND_MULTIPLE else Intent.ACTION_SEND
        
        // WhatsApp notoriously struggles with 'jid' when sharing multiple files.
        // For multiple files, we omit the JID to ensure it opens the contact picker reliably.
        val jid = if (uris.size == 1 && phone != null && phone.isNotEmpty()) "$phone@s.whatsapp.net" else null
        
        // Determine final MIME type
        val finalMimeType = if (uris.size > 1) {
            if (mimeTypes.size == 1 && mimeTypes.first() != "*") "${mimeTypes.first()}/*" else "*/*"
        } else {
             URLConnection.guessContentTypeFromName(File(files[0]).name) ?: "*/*"
        }

        val whatsappIntents = mutableListOf<Intent>()
        if (isWhatsappInstalled) {
            whatsappIntents.add(createFileIntent(action, uris, text, jid, "com.whatsapp", finalMimeType))
        }
        if (isBusinessInstalled) {
            whatsappIntents.add(createFileIntent(action, uris, text, jid, "com.whatsapp.w4b", finalMimeType))
        }

        startChooser(whatsappIntents, result)
    }

    private fun createFileIntent(
        action: String,
        uris: ArrayList<Uri>,
        text: String?,
        jid: String?,
        packageName: String,
        mimeType: String
    ): Intent {
        val intent = Intent(action).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = packageName
            type = mimeType
            
            if (jid != null) {
                putExtra("jid", jid)
            }
            if (text != null && text.isNotEmpty()) {
                putExtra(Intent.EXTRA_TEXT, text)
            }
            
            if (uris.size > 1) {
                putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
            } else {
                putExtra(Intent.EXTRA_STREAM, uris[0])
            }
        }
        
        // Explicitly grant permission to the target package for each URI
        uris.forEach { uri ->
            context.grantUriPermission(packageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        
        return intent
    }

    private fun startChooser(intents: List<Intent>, result: Result) {
        if (intents.isEmpty()) {
            result.error("WHATSAPP_NOT_INSTALLED", "No WhatsApp application found!", null)
            return
        }

        // If only one intent (one app installed), start it directly without chooser
        if (intents.size == 1) {
            try {
                context.startActivity(intents.first())
                result.success(true)
                return
            } catch (e: Exception) {
                Log.e("ERROR", "Failed to start direct activity: ${e.message}")
            }
        }

        val chooserIntent = Intent.createChooser(intents.first(), "Share with").apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            if (intents.size > 1) {
                putExtra(Intent.EXTRA_INITIAL_INTENTS, intents.drop(1).toTypedArray())
            }
        }

        try {
            context.startActivity(chooserIntent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to start activity: ${e.message}", null)
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            context.packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
