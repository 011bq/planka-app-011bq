import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // FocusNodes for each input field
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _selectedProtocol = 'https';
  final List<String> _protocolOptions = ['https', 'http', 'localhost'];
  final String _defaultDomain = 'planko.011bq.app'; // Set your domain internally

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  void _tryAutoLogin() async {
    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
    _selectedProtocol = provider.selectedProtocol;
    await provider.tryAutoLogin();
    if (provider.token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/projects');
    }
  }

  bool _validateAndFocusFields() {
    if (_usernameController.text.isEmpty) {
      FocusScope.of(context).requestFocus(_usernameFocusNode);
      return false;
    }
    if (_passwordController.text.isEmpty) {
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return false;
    }
    return true;
  }

  void _login() async {
    if (_validateAndFocusFields()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _selectedProtocol,
          _usernameController.text,
          _passwordController.text,
          _defaultDomain, // Use internal domain value
          context,
        );
        Navigator.of(context).pushReplacementNamed('/projects');
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'login_fields.0'.tr()),
              focusNode: _usernameFocusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _login(),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'login_fields.1'.tr()),
              obscureText: true,
              focusNode: _passwordFocusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: Text('login'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
