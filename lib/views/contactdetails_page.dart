import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  ContactDetailsPage({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    MemoryImage(Uint8List.fromList(contact.avatar ?? [])),
              ),
            ),

            SizedBox(height: 20),
            Text(
              'Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.displayName ?? 'No Name',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Phone:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.phones?.isNotEmpty == true
                  ? contact.phones!.first.value ?? 'No Phone'
                  : 'No Phone',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.emails?.isNotEmpty == true
                  ? contact.emails!.first.value ?? 'No Email'
                  : 'No Email',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Display other contact details dynamically
            // Iterate over all available properties
            for (var item in contact.toMap().entries)
              if (item.value != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      '${_capitalize(item.key)}:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${item.value}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }
}
