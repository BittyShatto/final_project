import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactPage extends StatefulWidget {
  ContactPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  getAllContacts() async {
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = _contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
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
            )
          ],
        ),
      ),
    );
  }

  Widget buildContactList(bool isSearching) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount:
          isSearching == true ? contactsFiltered.length : contacts.length,
      itemBuilder: (context, index) {
        Contact contact =
            isSearching == true ? contactsFiltered[index] : contacts[index];
        return ListTile(
          title: Text(contact.displayName ?? 'No Name'),
          subtitle: Text(
            contact.phones?.isNotEmpty == true
                ? contact.phones!.first.value ?? 'No Phone'
                : 'No Phone',
          ),
          leading: (contact.avatar != null && contact.avatar!.length > 0)
              ? CircleAvatar(
                  backgroundImage: MemoryImage(contact.avatar!),
                )
              : CircleAvatar(
                  child: Text(contact.initials()),
                ),
        );
      },
    );
  }
}
