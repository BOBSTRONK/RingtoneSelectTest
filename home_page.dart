import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frivia/pages/game_pages.dart';
import 'package:flutter_native_helper/flutter_native_helper.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:ringtone_set/ringtone_set.dart';
import 'package:app_settings/app_settings.dart';

class HomePage extends StatefulWidget {
  @override
  HomePage();

  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  String? diffcult;
  double _value = 1;
  double? _deviceHeight, _deviceWidth;
  AudioPlayer audioPlayer = AudioPlayer();

  List<Object?> result = [];
  List<SystemRingtoneModel> list = [];
  String? realPath;
  String? pathForRingtone;
  File? alarmFile;
  int selectedIndex = -1;

  static const channel = MethodChannel('com.example.pomo_app/mychannel');

  void initState() {
    super.initState();
    diffcult = 'Easy';
  }

  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _startGameButton(),
          GestureDetector(
            child: const Text(
              "Choose your Alarm",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await _showRingtones();
              setState(() {});
            },
          ),
          FloatingActionButton(onPressed: () async {
            await _showRingtones();
            setState(() {});
          }),
          _playAlarmButton(),
          _stopAlarmButton(),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Future<void> getRingtones() async {
    try {
      result = await channel.invokeMethod('getAllRingtones');
      print(result);
    } on PlatformException catch (ex) {
      print('Exception: $ex.message');
    }
  }

  Future<void> getRingTone() async {
    list = await FlutterNativeHelper.instance
        .getSystemRingtoneList(FlutterNativeConstant.systemRingtoneTypeAlarm);
  }

  Future<void> getPath(
      {required List<SystemRingtoneModel> inputList,
      required int index}) async {
    realPath = await FlutterNativeHelper.instance
        .transformUriToRealPath(inputList[index].ringtoneUri);
    alarmFile = File(realPath!);
  }

  Future<bool> playRingtone({required String uri}) async {
    var isSuccess =
        await FlutterNativeHelper.instance.playSystemRingtone(assignUri: uri);
    return isSuccess;
  }

  Future<bool> stopRingtone() async {
    var isSuccess = await FlutterNativeHelper.instance.stopSystemRingtone();
    return isSuccess;
  }

  Widget _playAlarmButton() {
    return ElevatedButton(
        onPressed: () {
          FlutterRingtonePlayer.playAlarm();
        },
        child: const Text('Play Alarm'));
  }

  Widget _stopAlarmButton() {
    return ElevatedButton(
        onPressed: () {
          FlutterRingtonePlayer.stop();
        },
        child: const Text('stop'));
  }

  Widget _startGameButton() {
    return MaterialButton(
      onPressed: () {
        getRingtones();
      },
      color: Colors.blue,
      minWidth: _deviceWidth! * 0.80,
      height: _deviceHeight! * 0.10,
      child: const Text(
        "Start",
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
        ),
      ),
    );
  }

  Future _showRingtones() async {
    getRingTone();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
                title: const Text("All the Ringtones:"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () async {
                        realPath = await FlutterNativeHelper.instance
                            .transformUriToRealPath(
                                list[selectedIndex].ringtoneUri);
                        alarmFile = File(realPath!);
                        await RingtoneSet.setAlarmFromFile(alarmFile!);
                        setState(() {
                          audioPlayer.stop();
                          audioPlayer.release();
                          print(selectedIndex);
                          Navigator.of(context).pop();
                        });
                        this.setState(() {});
                      },
                      child: const Text('Set as Alarm')),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          audioPlayer.stop();
                          audioPlayer.release();
                          Navigator.of(context).pop();
                        });
                      },
                      child: const Text('Back')),
                ],
                content: Container(
                  width: _deviceWidth! * 0.5,
                  height: _deviceHeight! * 0.5,
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, int index) {
                        var ringtoneName = list[index].ringtoneTitle;
                        return ListTile(
                          title: Text(ringtoneName),
                          selected: selectedIndex == index,
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.volume_down_outlined),
                            onPressed: () async {
                              pathForRingtone = await FlutterNativeHelper
                                  .instance
                                  .transformUriToRealPath(
                                      list[index].ringtoneUri);
                              int result = await audioPlayer
                                  .play(pathForRingtone!, isLocal: true);
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),
                        );
                      }),
                ));
          }));
        });
  }
}
