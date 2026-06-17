import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/online_cafe_service.dart';

class JoinCafeCodeDialog extends StatefulWidget {
  const JoinCafeCodeDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const JoinCafeCodeDialog(),
    );
  }

  @override
  State<JoinCafeCodeDialog> createState() => _JoinCafeCodeDialogState();
}

class _JoinCafeCodeDialogState extends State<JoinCafeCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final normalized = OnlineCafeService.normalizeJoinCode(_controller.text);
    if (normalized.length != OnlineCafeService.joinCodeLength) {
      setState(() {
        _errorMessage = 'Enter a ${OnlineCafeService.joinCodeLength}-character café code.';
      });
      return;
    }
    Navigator.of(context).pop(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Online Café'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Enter the café code your friend shared.'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('join_cafe_code_field'),
            controller: _controller,
            autofocus: true,
            maxLength: OnlineCafeService.joinCodeLength,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
            ],
            decoration: InputDecoration(
              labelText: 'Café code',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            onChanged: (_) => setState(() => _errorMessage = null),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('join_cafe_confirm'),
          onPressed: _submit,
          child: const Text('Join'),
        ),
      ],
    );
  }
}
