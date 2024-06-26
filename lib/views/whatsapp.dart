import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void openWhatsApp(BuildContext context, String message) async {
  var whatsapp = "+919747727283";
  var whatsappWebURL =
      "https://web.whatsapp.com/send?phone=$whatsapp&text=${Uri.parse(message)}";
  var whatsappURL_android =
      "http://api.whatsapp.com/send?phone=$whatsapp&text=${Uri.parse(message)}";

  try {
    if (Platform.isIOS) {
      if (await canLaunch(whatsappWebURL)) {
        await launch(whatsappWebURL);
      } else {
        throw 'Could not launch $whatsappWebURL';
      }
    } else {
      if (await canLaunch(whatsappURL_android)) {
        await launch(whatsappURL_android);
      } else {
        throw 'Could not launch $whatsappURL_android';
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

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
              openWhatsApp(context, message); // Use the openWhatsApp function
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
