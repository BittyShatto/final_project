import 'package:fast_contacts/fast_contacts.dart';
import 'package:final_project/controllers/auth_services.dart';
import 'package:final_project/views/contact_page.dart';
import 'package:final_project/views/whatsapp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher_android/url_launcher_android.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          launchButton(
            title: 'Launch Phone Number',
            icon: Icons.phone,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ContactPage()));
            },
          ),
          launchButton(
            title: 'Launch Whatsapp',
            icon: Icons.language,
            onPressed: () {
              {
                openWhatsApp(context);
              }
            },
          ),
        ]),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  maxRadius: 32,
                  child: Text(FirebaseAuth.instance.currentUser!.email
                      .toString()[0]
                      .toUpperCase()),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(FirebaseAuth.instance.currentUser!.email.toString())
              ],
            )),
            ListTile(
              onTap: () {
                AuthService().logout();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Logged Out")));
                Navigator.pushReplacementNamed(context, "/login");
              },
              leading: Icon(Icons.logout_outlined),
              title: Text("Logout"),
            )
          ],
        ),
      ),
    );
  }

  Widget launchButton({
    required String title,
    required IconData icon,
    required Function() onPressed,
  }) {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue)),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
