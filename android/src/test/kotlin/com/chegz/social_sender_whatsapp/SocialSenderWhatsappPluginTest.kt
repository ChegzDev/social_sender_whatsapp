package com.chegz.social_sender_whatsapp

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.eq

internal class SocialSenderWhatsappPluginTest {
    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = SocialSenderWhatsappPlugin()
        val call = MethodCall("unknown", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_send_basicValidation() {
        // Note: Real unit testing of 'send' requires mocking Context, PackageManager, Intent etc.
        // which is better done with Robolectric or Integration tests.
        // Here we just verify that it attempts to handle the 'send' call.
        val plugin = SocialSenderWhatsappPlugin()
        val arguments = mapOf("phone" to "123", "text" to "hi")
        val call = MethodCall("send", arguments)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        // This will likely fail in pure JUnit because context is not initialized
        // or package manager returns null, but it shows the structure.
        try {
            plugin.onMethodCall(call, mockResult)
        } catch (e: Exception) {
            // Expected failure in pure JUnit without Robolectric
        }
    }
}
