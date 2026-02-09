package com.budget.lens

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "backup_channel"
	private val CREATE_BACKUP = 1001
	private val RESTORE_BACKUP = 1002

	private var pendingBackupData: ByteArray? = null
	private var pendingResult: MethodChannel.Result? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"exportBackup" -> {
						val args = call.arguments
						if (args is ByteArray) {
							pendingBackupData = args
							pendingResult = result
							createBackupFile()
						} else {
							result.error("INVALID_ARGS", "Expected byte array", null)
						}
					}
					"importBackup" -> {
						pendingResult = result
						openBackupFile()
					}
					else -> result.notImplemented()
				}
			}
	}

	private fun createBackupFile() {
		val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
			addCategory(Intent.CATEGORY_OPENABLE)
			type = "application/json"
			putExtra(Intent.EXTRA_TITLE, "budgetlens_backup_${System.currentTimeMillis()}.json")
		}
		startActivityForResult(intent, CREATE_BACKUP)
	}

	private fun openBackupFile() {
		val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
			addCategory(Intent.CATEGORY_OPENABLE)
			type = "application/json"
		}
		startActivityForResult(intent, RESTORE_BACKUP)
	}

	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)

		if (resultCode != Activity.RESULT_OK || data?.data == null) {
			pendingResult?.success(null)
			pendingBackupData = null
			pendingResult = null
			return
		}

		val uri: Uri = data.data!!

		try {
			when (requestCode) {
				CREATE_BACKUP -> {
					val bytes = pendingBackupData
					if (bytes != null) {
						contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
						pendingResult?.success(null)
					} else {
						pendingResult?.error("NO_DATA", "No data to write", null)
					}
				}
				RESTORE_BACKUP -> {
					val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
					pendingResult?.success(bytes)
				}
			}
		} catch (e: Exception) {
			pendingResult?.error("IO_ERROR", e.message, null)
		} finally {
			pendingBackupData = null
			pendingResult = null
		}
	}
}
