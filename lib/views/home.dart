import 'package:final_project/views/whatsapp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'contactdetails_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated, show contacts page
          return MyContactsPage();
        } else {
          // User is not authenticated, show login page
          return MyLoginPage();
        }
      },
    );
  }
}

class MyLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Replace this with your authentication logic
            await FirebaseAuth.instance.signInAnonymously();
          },
          child: Text('Log in anonymously'),
        ),
      ),
    );
  }
}

class MyContactsPage extends StatefulWidget {
  @override
  _MyContactsPageState createState() => _MyContactsPageState();
}

class _MyContactsPageState extends State<MyContactsPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController _searchController = TextEditingController();
  TextEditingController _messageController =
      TextEditingController(); // Add message controller

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  Future<void> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      PermissionStatus status = await Permission.contacts.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Handle denied permission, e.g., show a message or navigate to settings
        return;
      }
      isGranted = status.isGranted;
    }
    if (isGranted) {
      List<Contact> _contacts = (await ContactsService.getContacts()).toList();
      setState(() {
        contacts = _contacts;
        contactsFiltered = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              // Implement call logs functionality
              try {
                // Example: Open the default phone dialer app
                String url = 'tel:';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                print('Error launching call logs: $e');
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  filterContacts(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Add some space
            TextField(
              // Add TextField for message input
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Enter Message',
                border: OutlineInputBorder(),
              ),
            ),
            Expanded(
              child: buildContactList(isSearching),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactList(bool isSearching) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: isSearching ? contactsFiltered.length : contacts.length,
      itemBuilder: (context, index) {
        Contact contact =
            isSearching ? contactsFiltered[index] : contacts[index];
        return GestureDetector(
          onTap: () {
            // Handle contact tap, navigate to details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactDetailsPage(contact: contact),
              ),
            );
          },
          child: ExpansionTile(
            title: ListTile(
              title: Text(contact.displayName ?? 'No Name'),
              subtitle: Text(
                contact.phones?.isNotEmpty == true
                    ? contact.phones!.first.value ?? 'No Phone'
                    : 'No Phone',
              ),
              leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(contact.avatar!),
                    )
                  : CircleAvatar(
                      child: Text(contact.initials()),
                    ),
              trailing: IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  // Handle contact details button press
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactDetailsPage(contact: contact),
                    ),
                  );
                },
              ),
            ),
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.sms),
                      onPressed: () {
                        // Handle SMS button press
                        launch(
                            'sms:+919188278975?body=${_messageController.text}');
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () async {
                        // Handle call button press
                        String telurl = "tel:9188278975";
                        if (await canLaunchUrlString(telurl)) {
                          launchUrlString(telurl);
                        } else {
                          print("Can't launch $telurl");
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () {
                        // Handle message button press
                        openWhatsApp(context, _messageController.text);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void filterContacts(String query) {
    setState(() {
      contactsFiltered = contacts
          .where((contact) =>
              contact.displayName
                  ?.toLowerCase()
                  .contains(query.toLowerCase()) ??
              false)
          .toList();
    });
  }
}
