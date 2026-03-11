import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        actions: [IconButton(onPressed: () => auth.signOut(), icon: Icon(Icons.logout))],
      ),
      body: Center(child: Text('Admin dashboard for ${auth.appUser?.name ?? ''}')),
    );
  }
}
