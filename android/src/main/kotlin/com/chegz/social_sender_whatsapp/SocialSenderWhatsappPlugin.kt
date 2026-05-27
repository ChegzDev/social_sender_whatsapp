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
                        putExtra(Intent.EXTRA_TEXT, text ?: "")
                        `package` = "com.whatsapp"
                    }
                )
            }
            if (isBusinessInstalled) {
                whatsappIntents.add(
                    Intent(Intent.ACTION_SEND).apply {
                        flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text ?: "")
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
        try {
            for (filePath in files) {
                val file = File(filePath)
                val uri = FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
                uris.add(uri)
            }
        } catch (e: Exception) {
            result.error("FILE_NOT_FOUND", "Error getting URI for file: ${e.message}", null)
            return
        }

        val whatsappIntents = mutableListOf<Intent>()
        val action = if (uris.size > 1) Intent.ACTION_SEND_MULTIPLE else Intent.ACTION_SEND
        val jid = if (phone != null && phone.isNotEmpty()) "$phone@s.whatsapp.net" else null

        if (isWhatsappInstalled) {
            whatsappIntents.add(createFileIntent(action, uris, text, jid, "com.whatsapp"))
        }
        if (isBusinessInstalled) {
            whatsappIntents.add(createFileIntent(action, uris, text, jid, "com.whatsapp.w4b"))
        }

        startChooser(whatsappIntents, result)
    }

    private fun createFileIntent(
        action: String,
        uris: ArrayList<Uri>,
        text: String?,
        jid: String?,
        packageName: String
    ): Intent {
        return Intent(action).apply {
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            `package` = packageName
            type = "*/*"
            if (jid != null) {
                putExtra("jid", jid)
            }
            if (text != null) {
                putExtra(Intent.EXTRA_TEXT, text)
            }
            if (uris.size > 1) {
                putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris)
            } else {
                putExtra(Intent.EXTRA_STREAM, uris[0])
            }
        }
    }

    private fun startChooser(intents: List<Intent>, result: Result) {
        if (intents.isEmpty()) {
            result.error("WHATSAPP_NOT_INSTALLED", "No WhatsApp application found!", null)
            return
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
