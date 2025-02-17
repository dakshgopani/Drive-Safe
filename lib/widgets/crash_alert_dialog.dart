import 'dart:async';
import 'package:flutter/material.dart';

class CrashAlertDialog extends StatefulWidget {
  final VoidCallback onEmergencyTriggered;
  final VoidCallback onDialogClosed;

  CrashAlertDialog({required this.onEmergencyTriggered, required this.onDialogClosed});

  @override
  _CrashAlertDialogState createState() => _CrashAlertDialogState();
}

class _CrashAlertDialogState extends State<CrashAlertDialog> {
  int _secondsRemaining = 10;
  late Timer _timer;
  bool _isResponded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _triggerEmergency();
      }
    });
  }

  void _respond() {
    _isResponded = true;
    _timer.cancel();
    widget.onDialogClosed();
    Navigator.of(context).pop();
  }

  void _triggerEmergency() {
    if (!_isResponded) {
      widget.onEmergencyTriggered();
      _respond();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.blueAccent,
      title: Text(
        '🚨 Possible Crash Detected!',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you okay? If no response in $_secondsRemaining seconds, emergency services will be contacted.',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            value: _secondsRemaining / 10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _respond,
          child: Text('I\'m OK', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            _triggerEmergency();
          },
          child: Text('Need Help', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}
