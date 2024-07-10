import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(InstallProgressApp());

class InstallProgressApp extends StatefulWidget {
  @override
  _InstallProgressAppState createState() => _InstallProgressAppState();
}

class _InstallProgressAppState extends State<InstallProgressApp> {
  static const platform = MethodChannel('com.example.install_progress_app/progress');
  bool _isAppInstalled = false;
  String _appPackageName = 'jp.co.mixi.monsterstrike'; // モンスターストライクのパッケージ名
  Timer? _timer;
  double _progress = 0.0;
  bool _nativeProgressAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkIfAppInstalled(); // アプリがインストールされているかを定期的にチェック
    _startProgressMonitoring(); // インストール進捗の監視を開始
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
    } else {
      throw 'Could not launch $url';
    }
  }

  // ネイティブコードからインストール進捗を取得するメソッド
  void _startProgressMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final int progress = await platform.invokeMethod('getProgress');
        if (progress >= 0) {
          setState(() {
            _progress = progress / 100.0;
            _nativeProgressAvailable = true;
          });
          print("Progress from native: $progress"); // デバッグ用ログ出力
        } else {
          setState(() {
            _nativeProgressAvailable = false;
          });
          print("No progress available from native"); // デバッグ用ログ出力
        }
      } on PlatformException catch (e) {
        print("Failed to get progress: '${e.message}'.");
      }
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
                  Text(_nativeProgressAvailable
                      ? 'Installing Monster Strike...'
                      : 'Monitoring installation progress...'), // インストール中のメッセージ
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
