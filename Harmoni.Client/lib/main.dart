import 'package:flutter/material.dart';
import 'package:harmoni/harmoni.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const apiKey = "AIzaSyCR1-M2rE8VNr667RuR6VI4sY9GVZipNok";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: apiKey);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(Harmoni());
}
