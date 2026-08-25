package org.traccar.client

import android.os.Process
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.DataOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "org.traccar.client/root"
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isRootAvailable" -> {
                    executor.execute {
                        val isRoot = checkRootAccess()
                        runOnUiThread {
                            result.success(isRoot)
                        }
                    }
                }
                "applyRootKeepAlive" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    executor.execute {
                        val success = if (enable) applyKeepAlive() else removeKeepAlive()
                        runOnUiThread {
                            result.success(success)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkRootAccess(): Boolean {
        var process: java.lang.Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val exitCode = process.waitFor()
            exitCode == 0
        } catch (e: Exception) {
            false
        } finally {
            process?.destroy()
        }
    }

    private fun applyKeepAlive(): Boolean {
        val pid = Process.myPid()
        val pkg = packageName
        val commands = arrayOf(
            // 1. 将自身进程优先级提升至系统最高核心级别 (-1000) 彻底免疫 LMK 查杀
            "echo -1000 > /proc/$pid/oom_score_adj",
            // 2. 将应用加入 Doze 白名单
            "dumpsys deviceidle whitelist +$pkg",
            // 3. 允许后台无限制常驻与前台服务启动
            "cmd appops set $pkg RUN_IN_BACKGROUND allow",
            "cmd appops set $pkg RUN_ANY_IN_BACKGROUND allow",
            "cmd appops set $pkg START_FOREGROUND allow"
        )
        return executeRootCommands(commands)
    }

    private fun removeKeepAlive(): Boolean {
        val pid = Process.myPid()
        val pkg = packageName
        val commands = arrayOf(
            // 恢复默认 oom 优先级
            "echo 0 > /proc/$pid/oom_score_adj",
            "dumpsys deviceidle whitelist -$pkg"
        )
        return executeRootCommands(commands)
    }

    private fun executeRootCommands(commands: Array<String>): Boolean {
        var process: java.lang.Process? = null
        var os: DataOutputStream? = null
        return try {
            process = Runtime.getRuntime().exec("su")
            os = DataOutputStream(process.outputStream)
            for (cmd in commands) {
                os.writeBytes(cmd + "\n")
            }
            os.writeBytes("exit\n")
            os.flush()
            val exitCode = process.waitFor()
            exitCode == 0
        } catch (e: Exception) {
            false
        } finally {
            try {
                os?.close()
            } catch (_: Exception) {}
            process?.destroy()
        }
    }
}
