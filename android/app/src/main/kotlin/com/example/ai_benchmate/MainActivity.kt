package com.example.ai_benchmate

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {

    private val channelName = "ai_benchmate/document_picker"
    private val requestCode = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "pickDocument" -> {
                    if (pendingResult != null) {
                        result.error("BUSY", "Picker is already open.", null)
                        return@setMethodCallHandler
                    }

                    pendingResult = result

                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "*/*"
                        putExtra(
                            Intent.EXTRA_MIME_TYPES,
                            arrayOf(
                                "application/pdf",
                                "image/jpeg",
                                "image/png"
                            )
                        )
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }

                    startActivityForResult(intent, requestCode)
                }

                else -> result.notImplemented()
            }
        }
    }

    @Deprecated("Deprecated in Android, retained for Flutter activity result handling")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != this.requestCode) return

        val result = pendingResult ?: return
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        try {
            val uri: Uri = data.data!!
            val originalName = getFileName(uri)
            val extension = originalName.substringAfterLast(
                ".",
                ""
            ).lowercase()

            if (extension !in listOf("pdf", "jpg", "jpeg", "png")) {
                result.error(
                    "INVALID_FILE",
                    "Only PDF, JPG, JPEG and PNG files are supported.",
                    null
                )
                return
            }

            val temporaryDirectory = File(
                cacheDir,
                "document_picker/${UUID.randomUUID()}"
            )
            temporaryDirectory.mkdirs()

            val destination = File(temporaryDirectory, originalName)

            contentResolver.openInputStream(uri).use { input ->
                if (input == null) {
                    throw Exception("Unable to read selected file.")
                }

                FileOutputStream(destination).use { output ->
                    input.copyTo(output)
                }
            }

            result.success(
                mapOf(
                    "path" to destination.absolutePath,
                    "name" to originalName
                )
            )

        } catch (e: Exception) {
            result.error("PICK_ERROR", e.message, null)
        }
    }

    private fun getFileName(uri: Uri): String {
        var name = "document"

        val cursor: Cursor? = contentResolver.query(
            uri,
            null,
            null,
            null,
            null
        )

        cursor?.use {
            if (it.moveToFirst()) {
                val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) {
                    name = it.getString(index) ?: name
                }
            }
        }

        return name.replace(Regex("[\\\\/:*?\"<>|]"), "_")
    }
}