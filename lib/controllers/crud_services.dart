import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CRUDService {
  User? user = FirebaseAuth.instance.currentUser;

  // add new contacts to firestore
  Future addNewContacts(String name, String phone, String email) async {
    Map<String, dynamic> data = {"name": name, "email": email, "phone": phone};
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("contacts")
          .add(data);
      print("Document Added");
    } catch (e) {
      print(e.toString());
    }
  }

  // read documents inside firestore
  Stream<QuerySnapshot> getContacts({String? searchQuery}) async* {
    var contactsQuery = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("contacts")
        .orderBy("name");

    // a filter to perform search
    if (searchQuery != null && searchQuery.isEmpty) {
      String searchEnd = searchQuery + "\uf8ff";
      contactsQuery = contactsQuery.where("name",
          isGreaterThanOrEqualTo: searchQuery, isLessThan: searchEnd);
    }

    var contacts = contactsQuery.snapshots();
    yield* contacts;
  }
}
