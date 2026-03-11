import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Home'),
        actions: [IconButton(onPressed: () => auth.signOut(), icon: Icon(Icons.logout))],
      ),
      body: Center(child: Text('Hi ${auth.appUser?.name ?? 'Friend'}!')),
    );
  }
}
