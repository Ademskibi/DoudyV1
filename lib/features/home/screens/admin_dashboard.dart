import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Admin', style: Theme.of(context).textTheme.titleLarge),
              IconButton(onPressed: () => auth.signOut(), icon: Icon(Icons.logout)),
            ]),
            Expanded(child: Center(child: Text('Admin dashboard for ${auth.appUser?.name ?? ''}'))),
          ]),
        ),
      ),
    );
  }
}
