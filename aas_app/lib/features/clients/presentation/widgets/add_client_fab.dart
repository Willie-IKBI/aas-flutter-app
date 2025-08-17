import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../pages/add_client_page.dart';

class AddClientFAB extends StatelessWidget {
  const AddClientFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddClientPage(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 8,
      icon: const Icon(Icons.add),
      label: const Text('Add Client'),
    );
  }
}
