import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Home'),
        actions: [
          IconButton(onPressed: () => auth.signOut(), icon: Icon(Icons.logout)),
        ],
      ),
      body: Center(child: Text('Welcome, ${auth.appUser?.name ?? 'Parent'}')),
    );
  }
}
