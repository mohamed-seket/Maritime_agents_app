import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login.dart';
import 'auth/reset_pwd.dart';
import 'auth/signup_page.dart';
import 'mission_dashboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaSOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => Login());
      case '/mission_dashboard':
        if (arguments != null) {
          final String token = arguments['token'];
          return MaterialPageRoute(builder: (context) => MissionDashboard(token: token));
        }
        return _errorRoute('Token not found for Mission Dashboard');
      case '/reset_pwd':
        return MaterialPageRoute(builder: (context) => ResetPwd());
      case '/signup_page':
        return MaterialPageRoute(builder: (context) => SignupPage());
      default:
        return _errorRoute('Page not found');
    }
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text(message)),
      );
    });
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return MissionDashboard(token: snapshot.data!);
        } else {
          return Login();
        }
      },
    );
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
