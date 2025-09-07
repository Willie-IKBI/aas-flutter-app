import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class ClientSearch extends StatefulWidget {
  const ClientSearch({
    super.key,
    required this.onSearchChanged,
  });
  final Function(String) onSearchChanged;

  @override
  State<ClientSearch> createState() => _ClientSearchState();
}

class _ClientSearchState extends State<ClientSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        style: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search clients...',
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
