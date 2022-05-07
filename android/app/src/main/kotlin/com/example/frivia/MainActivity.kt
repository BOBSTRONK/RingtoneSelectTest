package com.example.frivia

import android.content.Context
import android.database.Cursor
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel



class MainActivity: FlutterActivity() {
    // add the name of the channel that we made in flutter code
    private val flutter_channel = "com.example.pomo_app/mychannel"
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel =MethodChannel(flutterEngine.dartExecutor.binaryMessenger,flutter_channel)

        channel.setMethodCallHandler{
            call,result ->when(call.method){
                "getAllRingtones" ->{
                    result.success(getAllRingtones(this))
                }
            }
        }
    }
    private fun getAllRingtones(context:Context):List<String>{
        val manager = RingtoneManager(context)
        manager.setType(RingtoneManager.TYPE_ALARM)

        val cursor: Cursor = manager.cursor

        val list : MutableList<String> = mutableListOf()
        while (cursor.moveToNext()){
            val notificationTitle : String = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
            list.add(notificationTitle)
        }
        return list
    }
}
