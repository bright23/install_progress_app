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
  String _appPackageName = 'jp.co.mixi.monsterstrike';
  Timer? _timer;
  double _progress = 0.0;
  bool _nativeProgressAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkIfAppInstalled();
    _startProgressMonitoring();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkIfAppInstalled() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool isInstalled = await DeviceApps.isAppInstalled(_appPackageName);
      if (isInstalled) {
        setState(() {
          _isAppInstalled = true;
          _progress = 1.0;
        });
        timer.cancel();
      }
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _startProgressMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final int progress = await platform.invokeMethod('getProgress');
        if (progress >= 0) {
          setState(() {
            _progress = progress / 100.0;
            _nativeProgressAvailable = true;
          });
        } else {
          setState(() {
            _nativeProgressAvailable = false;
          });
        }
      } on PlatformException catch (e) {
        print("Failed to get progress: '${e.message}'.");
      }
    });
  }

  void _startNotificationService() {
    platform.invokeMethod('startNotificationService');
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
              ElevatedButton(
                onPressed: () {
                  _launchURL('https://play.google.com/store/apps/details?id=$_appPackageName');
                  _startNotificationService();
                },
                child: Text('Open Monster Strike in Play Store'),
              ),
              SizedBox(height: 20),
              _isAppInstalled
                  ? Text('Monster Strike is installed!')
                  : Column(
                children: <Widget>[
                  LinearProgressIndicator(value: _progress),
                  SizedBox(height: 20),
                  Text('${(_progress * 100).toStringAsFixed(0)}%'),
                  SizedBox(height: 20),
                  Text(_nativeProgressAvailable
                      ? 'Installing Monster Strike...'
                      : 'Monitoring installation progress...'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
