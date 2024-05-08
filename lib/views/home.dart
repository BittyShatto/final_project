import 'package:contacts_service/contacts_service.dart';
import 'package:final_project/controllers/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contactdetails_page.dart';
import 'whatsapp.dart';

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
  RefreshController refreshController = RefreshController(initialRefresh: true);

  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

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
        // Handle denied permission
        // Show a message or navigate to settings
        return;
      }
      isGranted = status.isGranted;
    }
    if (isGranted) {
      List<Contact> _contacts = await ContactsService.getContacts();
      if (_contacts.isNotEmpty) {
        setState(() {
          contacts = _contacts;
          contactsFiltered = _contacts;
          isLoading = false;
          refreshController.refreshCompleted();
        });
      } else {
        // Handle empty contact list
        // Show a message to inform the user
        setState(() {
          isLoading = false;
          refreshController.refreshCompleted();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              try {
                Contact contact = await ContactsService.openContactForm();
                if (contact == null) {
                  getContacts();
                }
              } on FormOperationException catch (e) {
                switch (e.errorCode) {
                  case FormOperationErrorCode.FORM_OPERATION_CANCELED:
                  case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
                  case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                    print(e.toString());
                    break;
                  default:
                  // Handle other cases if needed
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              try {
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
      body: SmartRefresher(
        controller: refreshController,
        header: WaterDropMaterialHeader(
          backgroundColor: Colors.black,
        ),
        onRefresh: () => getContacts(),
        child: Container(
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
              if (isLoading)
                CircularProgressIndicator()
              else if (contactsFiltered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text("No contacts found."),
                  ),
                )
              else
                Expanded(
                  child: buildContactList(isSearching),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContactList(bool isSearching) {
    final List<Contact> displayedContacts =
        isSearching ? contactsFiltered : contacts;

    return ListView.builder(
      itemCount: displayedContacts.length,
      itemBuilder: (context, index) {
        Contact contact = displayedContacts[index];
        return GestureDetector(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ExpansionTile(
              title: ListTile(
                title: Text(
                  contact.displayName ?? 'No Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value ?? 'No Phone'
                      : 'No Phone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.avatar!),
                      )
                    : CircleAvatar(
                        child: Text(contact.initials()),
                      ),
                contentPadding: EdgeInsets.zero,
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
                          launch(
                              'sms:${contact.phones!.first.value}?body=Hello');
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.call),
                        onPressed: () async {
                          String telurl = "tel:${contact.phones!.first.value}";
                          if (await canLaunch(telurl)) {
                            launch(telurl);
                          } else {
                            print("Can't launch $telurl");
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: ImageIcon(
                          AssetImage("images/WhatsApplogo.png"),
                          size: 24,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MessageDialog(
                                onSendMessage: (message) {
                                  openWhatsApp(context, message);
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
