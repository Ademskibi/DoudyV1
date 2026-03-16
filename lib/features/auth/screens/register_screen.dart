import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'parent';
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
              Text('Register', style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 12),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Full name')),
              SizedBox(height: 8),
              TextField(controller: _emailCtrl, decoration: InputDecoration(labelText: 'Email')),
              SizedBox(height: 8),
              TextField(controller: _passCtrl, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: ['parent', 'child', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r.capitalize()))).toList(),
                onChanged: (v) => setState(() => _role = v ?? 'parent'),
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        try {
                          await auth.signUpWithEmail(
                            name: _nameCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            password: _passCtrl.text,
                            role: _role,
                          );
                          if (_role == 'parent') GoRouter.of(context).go('/parent');
                          else if (_role == 'child') GoRouter.of(context).go('/child');
                          else GoRouter.of(context).go('/admin');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
                child: _loading ? CircularProgressIndicator(color: Colors.white) : Text('Register'),
              ),
              Spacer(),
              TextButton(onPressed: () => GoRouter.of(context).go('/login'), child: Text('Already have an account? Login')),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() => this.length > 0 ? this[0].toUpperCase() + substring(1) : this;
}
