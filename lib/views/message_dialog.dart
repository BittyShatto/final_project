import 'package:flutter/material.dart';

class MessageDialog extends StatefulWidget {
  final Function(String) onSendMessage;

  const MessageDialog({Key? key, required this.onSendMessage})
      : super(key: key);

  @override
  _MessageDialogState createState() => _MessageDialogState();
}

class _MessageDialogState extends State<MessageDialog> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Message'),
      content: TextField(
        controller: _messageController,
        decoration: InputDecoration(hintText: 'Enter your message here'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String message = _messageController.text.trim();
            if (message.isNotEmpty) {
              widget.onSendMessage(message);
            }
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Send'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
