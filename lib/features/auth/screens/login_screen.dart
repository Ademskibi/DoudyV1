import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _attemptLogin(AuthService auth) async {
    final id = _identifierCtrl.text.trim();
    final pwd = _passCtrl.text;

    if (id.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter identifier and password.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔥 Unified login (email / username / QR)
      await auth.signInWithIdentifier(
        identifier: id,
        password: pwd,
      );

      if (!mounted) return;

      final role = auth.appUser?.role;

      if (role == 'parent') {
        context.go('/parent');
      } else if (role == 'child') {
        context.go('/child');
      } else {
        context.go('/admin');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// ================= UI PARTS =================

  Widget _buildAuthForm(AuthService auth, {bool center = false}) {
    return Column(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Login', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 1.5.h),

        TextField(
          controller: _identifierCtrl,
          decoration: const InputDecoration(
            labelText: 'Email / Username / QR ID',
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(height: 1.5.h),

        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),

        SizedBox(height: 3.h),

        ElevatedButton(
          onPressed: _loading ? null : () => _attemptLogin(auth),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Login'),
        ),

        SizedBox(height: 1.h),

        OutlinedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  try {
                    await auth.signInWithGoogle();
                    if (!mounted) return;

                    final role = auth.appUser?.role;

                    if (role == 'parent') {
                      context.go('/parent');
                    } else if (role == 'child') {
                      context.go('/child');
                    } else {
                      context.go('/admin');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
        ),

        if (!center) SizedBox(height: 2.h),

        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text("Don't have an account? Register"),
        ),
      ],
    );
  }

  Widget _buildQRSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Quick Login', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 1.5.h),

        const Text('Scan QR code to autofill identifier'),

        SizedBox(height: 3.h),

        ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner,color: Colors.white,),
          label: const Text('Scan QR Code',style: TextStyle(color: Colors.white)),
          onPressed: () async {
            try {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => const QRScanScreen(),
                ),
              );

              if (result != null && result.isNotEmpty) {
                // 🔥 Smart validation
                if (result.contains('@')) {
                  _identifierCtrl.text = result;
                } else if (result.startsWith("USER_")) {
                  _identifierCtrl.text =
                      result.replaceFirst("USER_", "");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid QR format')),
                  );
                }
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Scanner error: $e')),
              );
            }
          },
        ),
      ],
    );
  }

  /// ================= MAIN BUILD =================

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 📱 Mobile layout: make scrollable to avoid keyboard overflow
              if (constraints.maxWidth < 600) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAuthForm(auth),
                        SizedBox(height: 2.h),
                        _buildQRSection(),
                      ],
                    ),
                  ),
                );
              }

              // 💻 Desktop layout: make left slightly smaller and vertically center
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(child: _buildAuthForm(auth, center: true)),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(flex: 2, child: _buildQRSection()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ================= QR SCANNER =================

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (_scanned) return;

          final barcode = capture.barcodes.first;
          final raw = barcode.rawValue;

          if (raw == null || raw.isEmpty) return;

          _scanned = true;
          controller.stop();

          Navigator.of(context).pop(raw);
        },
      ),
    );
  }
}