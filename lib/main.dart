import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'bloc_observer.dart';
import 'core/di/injection.dart' as di;
import 'core/notifications/notification_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Wajib dipasang sebelum runApp agar background handler aktif
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

  await di.init();

  Bloc.observer = AppBlocObserver();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}
