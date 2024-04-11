import 'package:final_project/controllers/crud_services.dart';
import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Add Contacts")),
        body: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter any Name" : null,
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), label: Text("Name")),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: TextFormField(
                        validator: (value) => value!.length < 10
                            ? "PhoneNumber Should have atleast 10 characters."
                            : null,
                        controller: _phoneController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text("PhoneNumber")),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * .9,
                      child: TextFormField(
                        // validator: (value) =>
                        //     value!.isEmpty ? "Email cannot be empty." : null,
                        controller: _emailController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), label: Text("Email")),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 65,
                      width: MediaQuery.of(context).size.width * .9,
                      child: ElevatedButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              CRUDService().addNewContacts(_nameController.text,
                                  _phoneController.text, _emailController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            "Create",
                            style: TextStyle(fontSize: 16),
                          ))),
                ],
              ),
            ),
          ),
        ));
  }
}
