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
        // ... existing code ...
    }

    @Test
    fun sanitizePhone_removesNonDigits() {
        val plugin = SocialSenderWhatsappPlugin()
        assert(plugin.sanitizePhone("+1 (234) 567-8900") == "12345678900")
        assert(plugin.sanitizePhone("1234567890") == "1234567890")
        assert(plugin.sanitizePhone(null) == null)
        assert(plugin.sanitizePhone("") == "")
    }
}
