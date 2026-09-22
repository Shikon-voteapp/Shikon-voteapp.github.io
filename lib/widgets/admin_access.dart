import 'package:flutter/material.dart';
import 'custom_dialog.dart';

class AdminAccessButton extends StatelessWidget {
  const AdminAccessButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAdminLoginDialog(context: context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.admin_panel_settings,
          color: Colors.grey.shade700,
          size: 20,
        ),
      ),
    );
  }
}

