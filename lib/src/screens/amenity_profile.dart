import 'package:book_my_spot_frontend/src/services/storageManager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmenityHeadProfile extends ConsumerStatefulWidget {
  const AmenityHeadProfile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AmenityHeadProfileState();
}

class _AmenityHeadProfileState extends ConsumerState<AmenityHeadProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
              onPressed: () {
                deleteAdminToken();
                context.go("/login");
              },
              child: Text("Logout"))),
    );
  }
}