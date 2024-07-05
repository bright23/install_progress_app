import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';
import 'dart:async';

void main() => runApp(InstallProgressApp());

class InstallProgressApp extends StatefulWidget {
  @override
  _InstallProgressAppState createState() => _InstallProgressAppState();
}

class _InstallProgressAppState extends State<InstallProgressApp> {
  bool _isAppInstalled = false;
  String _appPackageName = 'jp.co.mixi.monsterstrike'; // モンスターストライクのパッケージ名
  Timer? _timer;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkIfAppInstalled(); // アプリがインストールされているかを定期的にチェック
  }

  @override
  void dispose() {
    _timer?.cancel(); // タイマーをキャンセルしてリソースを解放
    super.dispose();
  }

  // モンスターストライクがインストールされているかを定期的にチェックするメソッド
  void _checkIfAppInstalled() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool isInstalled = await DeviceApps.isAppInstalled(_appPackageName);
      if (isInstalled) {
        setState(() {
          _isAppInstalled = true;
          _progress = 1.0; // インストールされている場合、進行状況を100%に設定
        });
        timer.cancel(); // タイマーをキャンセル
      }
    });
  }

  // 指定されたURLを開くメソッド
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      _simulateProgress(); // URLを開いた後、仮想的な進行状況をシミュレート
    } else {
      throw 'Could not launch $url';
    }
  }

  // 仮想的な進行状況をシミュレートするメソッド
  void _simulateProgress() {
    _progress = 0.0;
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _progress = 1.0; // 進行状況が100%に達したら設定
          timer.cancel(); // タイマーをキャンセル
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Install Progress App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Play Storeを開くボタン
              ElevatedButton(
                onPressed: () {
                  _launchURL('https://play.google.com/store/apps/details?id=$_appPackageName');
                },
                child: Text('Open Monster Strike in Play Store'),
              ),
              SizedBox(height: 20),
              // インストールの状態に応じて表示を切り替え
              _isAppInstalled
                  ? Text('Monster Strike is installed!') // アプリがインストールされている場合の表示
                  : Column(
                children: <Widget>[
                  LinearProgressIndicator(value: _progress), // 進行状況バー
                  SizedBox(height: 20),
                  Text('${(_progress * 100).toStringAsFixed(0)}%'), // 進行状況のパーセンテージ表示
                  SizedBox(height: 20),
                  Text('Installing Monster Strike...'), // インストール中のメッセージ
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
