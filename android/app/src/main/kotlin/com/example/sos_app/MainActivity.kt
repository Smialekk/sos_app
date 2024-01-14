package com.example.sos_app


import android.os.Bundle
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_sender_channel" // Nazwa kanału

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSMS") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")

                if (phoneNumber != null && message != null) {
                    try {
                        val smsManager: SmsManager = SmsManager.getDefault()
                        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        result.success("SMS sent successfully")
                    } catch (ex: Exception) {
                        result.error("ERROR", "Failed to send SMS", null)
                    }
                } else {
                    result.error("ERROR", "Phone number or message is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}


// import android.content.Intent
// import android.net.Uri
// import android.os.Bundle
// import io.flutter.embedding.android.FlutterActivity
// import io.flutter.plugin.common.MethodCall
// import io.flutter.plugin.common.MethodChannel

// class MainActivity: FlutterActivity() {
//     private val CHANNEL = "sms_sender_channel" // Nazwa kanału

//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//             if (call.method == "sendSMS") {
//                 val phoneNumber = call.argument<String>("phoneNumber")
//                 val message = call.argument<String>("message")

//                 if (phoneNumber != null && message != null) {
//                     try {
//                         // Utwórz Intent do wysłania SMS
//                         val smsUri = Uri.parse("smsto:$phoneNumber")
//                         val intent = Intent(Intent.ACTION_SENDTO, smsUri)
//                         intent.putExtra("sms_body", message)

//                         // Uruchom Intent
//                         startActivity(intent)
//                         result.success("SMS sent successfully")
//                     } catch (ex: Exception) {
//                         result.error("ERROR", "Failed to send SMS", null)
//                     }
//                 } else {
//                     result.error("ERROR", "Phone number or message is null", null)
//                 }
//             } else {
//                 result.notImplemented()
//             }
//         }
//     }
// }

