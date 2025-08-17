import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';
import '../pages/add_part_page.dart';

class AddPartFAB extends StatelessWidget {
  const AddPartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddPartPage(),
          ),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.add),
      label: const Text('Add Part'),
    );
  }
}
