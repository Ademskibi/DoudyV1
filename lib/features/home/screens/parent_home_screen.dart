import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Parent Home', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(onPressed: () => auth.signOut(), icon: Icon(Icons.logout)),
                ],
              ),
              Expanded(child: Center(child: Text('Welcome, ${auth.appUser?.name ?? 'Parent'}'))),
            ],
          ),
        ),
      ),
    );
  }
}
