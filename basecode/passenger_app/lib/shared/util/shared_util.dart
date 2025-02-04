import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class SharedUtil {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final logger = Logger();
  Timer? _audioTimer; // Store the timer globally

  //Open Options like whatsapp and SMS
  void sendSMS(String phoneNumber, String message) async {
    final logger = Logger();
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    logger.i("send sms : $phoneNumber");
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS: $smsUri';
      }
    } catch (e) {
      logger.e('Error sending SMS: $e');
    }
  }

  //Play audio
  Future<void> playAudio(String filePath) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
    if (filePath.isEmpty) {
      logger.e("Audio URL is empty: ${filePath}.aac");
      return;
    }
    try {
      await _audioPlayer.play(AssetSource(filePath), volume: 1);
    } catch (e) {
      logger.e("Error trying to play audio: $e");
    }
  }

  //Make vibrate
  Future<void> makePhoneVibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    } else {
      logger.e("Vibration is not available.");
    }
  }




Future<void> repeatAudio(String filePath) async {
  const duration = Duration(minutes: 5);
  const interval = Duration(seconds: 5); // Adjust this interval as needed
  final startTime = DateTime.now();

  _audioTimer = Timer.periodic(interval, (timer) async {
    if (DateTime.now().difference(startTime) >= duration) {
      timer.cancel(); // Stop repeating after 5 minutes
      _audioTimer = null;
      
    } else {
      await playAudio(filePath); // Call the playAudio function
    }
  });
}

void stopAudioLoop() {
  _audioTimer?.cancel();
  _audioTimer = null; // Reset the timer variable
}
}
