import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_management_provider.dart';

// Search Controller Provider
final searchControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  // Listen to text changes and update the user management state
  controller.addListener(() {
    ref.read(userManagementProvider.notifier).setSearchQuery(controller.text);
  });

  // Dispose controller when provider is disposed
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});
