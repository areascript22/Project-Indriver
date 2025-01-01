// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class TestPage extends StatefulWidget {
//   const TestPage({super.key});

//   @override
//   State<TestPage> createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
//   final SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _wordsSpoken = '';
//   double _confidenceLevel = 0;

//   @override
//   void initState() {
//     super.initState();
//     initSpeech();
//   }

//   void initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }

//   void _startListenning() async {
//     await _speechToText.listen(onResult: onSpeechResult);
//     setState(() {
//       _confidenceLevel = 0;
//     });
//   }

//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {});
//   }

//   void onSpeechResult(result) {
//     setState(() {
//       _wordsSpoken = '${result.recognizedWords}';
//       _confidenceLevel = result.confidence;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Speech"),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Container(
//               child: Text(_speechToText.isListening
//                   ? "Listenning..."
//                   : _speechEnabled
//                       ? "Tap the microfone to start listenning"
//                       : "Speech not available"),
//             ),
//             Expanded(
//                 child: Container(
//               child: Text(_wordsSpoken),
//             )),
//             if (_speechToText.isNotListening && _confidenceLevel > 0)
//               Text(
//                   "Confidence level ${(_confidenceLevel * 100).toStringAsFixed(1)}%"),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed:
//             _speechToText.isListening ? _stopListening : _startListenning,
//       ),
//     );
//   }
// }
