import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Contact List"),
        ),
        body: Container(
          height: double.infinity,
          child: FutureBuilder(
            future: getContacts(),
            builder: (context, AsyncSnapshot<List<Contact>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No contacts available."),
                );
              } else {
                // Sort the contacts based on display name
                snapshot.data!.sort((a, b) =>
                    (a.displayName ?? "").compareTo(b.displayName ?? ""));

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Contact contact = snapshot.data![index];
                    return ListTile(
                      leading: const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      title: Text(contact.displayName ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (contact.phones?.isNotEmpty == true)
                            Text("Phone: ${contact.phones!.first.value ?? ""}"),
                          if (contact.emails?.isNotEmpty == true)
                            Text("Email: ${contact.emails!.first.value ?? ""}"),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      PermissionStatus status = await Permission.contacts.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Handle denied permission, e.g., show a message or navigate to settings
        return [];
      }
      isGranted = status.isGranted;
    }
    if (isGranted) {
      return await ContactsService.getContacts();
    }
    return [];
  }
}

void main() {
  runApp(ContactPage());
}
