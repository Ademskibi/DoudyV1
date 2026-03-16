import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../../../core/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Login', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 12),
              TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 12),
              TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        try {
                          await auth.signInWithEmail(email: _emailCtrl.text.trim(), password: _passCtrl.text);
                          if (!mounted) return;
                          const maxWait = Duration(seconds: 5);
                          const poll = Duration(milliseconds: 250);
                          var waited = Duration.zero;
                          while (auth.appUser == null && waited < maxWait) {
                            await Future.delayed(poll);
                            waited += poll;
                          }

                          final role = auth.appUser?.role;
                          if (role == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to determine user role. Please try again.')));
                            return;
                          }
                          if (role == 'parent') GoRouter.of(context).go('/parent');
                          else if (role == 'child') GoRouter.of(context).go('/child');
                          else GoRouter.of(context).go('/admin');
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Login'),
              ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                icon: Icon(Icons.login, color: AppColors.blue),
                label: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() => _loading = true);
                  try {
                    await auth.signInWithGoogle();
                    if (!mounted) return;
                    const maxWait = Duration(seconds: 5);
                    const poll = Duration(milliseconds: 250);
                    var waited = Duration.zero;
                    while (auth.appUser == null && waited < maxWait) {
                      await Future.delayed(poll);
                      waited += poll;
                    }

                    final role = auth.appUser?.role;
                    if (role == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to determine user role. Please try again.')));
                      return;
                    }
                    if (role == 'parent') GoRouter.of(context).go('/parent');
                    else if (role == 'child') GoRouter.of(context).go('/child');
                    else GoRouter.of(context).go('/admin');
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
              ),
              Spacer(),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/register'),
                child: Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
