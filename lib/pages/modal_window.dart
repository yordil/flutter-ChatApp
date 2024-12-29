import 'package:flutter/material.dart';

class LogoutModal extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutModal({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('No'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text('Yes'),
        ),
      ],
    );
  }
}
