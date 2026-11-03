import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/helpers/location_permission_helper.dart';
import '../../../../../core/services/firebase_messaging_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _minDelayDone = false;
  String? _pendingRoute;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final pending = _pendingRoute;
      setState(() => _minDelayDone = true);
      if (pending != null) context.go(pending);
    });
  }

  Future<void> _requestPermissions() async {
    await sl<FirebaseMessagingService>().requestPermission();
    await LocationPermissionHelper.request();
  }

  void _navigate(String route) {
    if (_minDelayDone) {
      context.go(route);
    } else {
      _pendingRoute = route;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigate('/home');
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          _navigate('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5A623),
        body: Center(
          child: Image.asset(
            'assets/Logo_white.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
