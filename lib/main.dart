import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
}

class AuthToken {
  final String token;

  AuthToken({required this.token});
}

class AuthProvider with ChangeNotifier {
  User? _user;
  AuthToken? _authToken;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('authToken');

    if (savedToken != null) {
      _authToken = AuthToken(token: savedToken);
      notifyListeners();
    }
  }

  User? get user => _user;
  AuthToken? get authToken => _authToken;

  bool get isAuthenticated => _user != null;

  void login(User user, AuthToken authToken) {
    _user = user;
    _authToken = authToken;
    _saveAuthTokenToPrefs(authToken.token);
    notifyListeners();
  }

  void logout() {
    _user = null;
    _authToken = null;
    _clearAuthTokenFromPrefs();
    notifyListeners();
  }

  void _saveAuthTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('authToken', token);
  }

  void _clearAuthTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('authToken');
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    // Replace the following logic with your custom authentication logic
    if (username == 'shubham' && password == 'password') {
      final user = User(id: '1', email: 'shubham@gmail.com');
      final authToken = AuthToken(token: 'QpwL5tke4Pnpja7X4');

      Provider.of<AuthProvider>(context, listen: false).login(user, authToken);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('Invalid username or password'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        color: Colors.blue.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                width: 300,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authToken = Provider.of<AuthProvider>(context).authToken;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Home Page!'),
            if (authToken != null) Text('Token: ${authToken.token}'),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Login Example',
        theme: ThemeData(
          primaryColor: Colors.blue, // Set your desired primary color
        ),
        home: LoginPage(),
      ),
    );
  }
}
