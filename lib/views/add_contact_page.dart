import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class AddContact extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Validate input
                if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
                  // Show error message if any field is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter name and phone number')),
                  );
                  return;
                }

                // Create new contact
                Contact contact = Contact();
                contact.givenName = _nameController.text;
                contact.phones = [Item(label: 'mobile', value: _phoneController.text)];

                // Add contact to device's default contacts
                await ContactsService.addContact(contact);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Contact added successfully')),
                );

                // Clear text fields
                _nameController.clear();
                _phoneController.clear();
              },
              child: Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}
