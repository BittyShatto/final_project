import 'dart:ui';

import 'package:final_project/controllers/auth_services.dart';
import 'package:final_project/views/contactdetails_page.dart';
import 'package:final_project/views/whatsapp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          IconButton(
            icon: Icon(Icons.add), // Use the Icons.add for adding contacts
            onPressed: () {
              // Implement adding contacts functionality
              // You can add your logic here to handle adding contacts
            },
          ),
        ],
      ),
      drawer: MyDrawer(logoutCallback: () {
        FirebaseAuth.instance.signOut();
      }),
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
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 5), // Adjust the horizontal padding as needed
            child: ExpansionTile(
              title: ListTile(
                title: Text(
                  contact.displayName ?? 'No Name',
                  maxLines:
                      1, // Set maxLines to 1 to ensure the name is displayed on a single line
                  overflow:
                      TextOverflow.ellipsis, // Handle overflow with ellipsis
                ),
                subtitle: Text(
                  contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value ?? 'No Phone'
                      : 'No Phone',
                  maxLines:
                      1, // Set maxLines to 1 to ensure the phone number is displayed on a single line
                  overflow:
                      TextOverflow.ellipsis, // Handle overflow with ellipsis
                ),
                leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.avatar!),
                      )
                    : CircleAvatar(
                        child: Text(contact.initials()),
                      ),
                contentPadding: EdgeInsets.zero, // Remove default padding
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
                          launch('sms:+919747727283?body=Hello');
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () async {
                          // Handle call button press
                          String telurl = "tel:9747727283";
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
                        icon: ImageIcon(
                          AssetImage('assets/images/whatsapp.png'),
                          size: 24,
                        ),
                        onPressed: () {
                          // Display the MessageDialog as a dialog box
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MessageDialog(
                                onSendMessage: (message) {
                                  // Handle sending the message
                                  openWhatsApp(context,
                                      message); // Call openWhatsApp function here
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          // Navigate to ContactDetailsPage
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
                  ],
                ),
              ],
            ),
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

class MyDrawer extends StatelessWidget {
  final VoidCallback logoutCallback;

  const MyDrawer({Key? key, required this.logoutCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  maxRadius: 32,
                  child: Text(
                    FirebaseAuth.instance.currentUser!.email![0].toUpperCase(),
                  ),
                ),
                SizedBox(height: 10),
                Text(FirebaseAuth.instance.currentUser!.email!),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              AuthService().logout();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Logged Out")));
              Navigator.pushReplacementNamed(context, "/login");
            },
            leading: Icon(Icons.logout),
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
