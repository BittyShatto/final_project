import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

openWhatsApp(BuildContext context) async {
  var whatsapp = "+916238021161";
  var whatsappWebURL =
      "https://web.whatsapp.com/send?phone=$whatsapp&text=${Uri.parse("hello Dona!What are you doing")}";
  var whatsappURL_android =
      "http://api.whatsapp.com/send?phone=$whatsapp&text=hello Dona!What are you doing";

  try {
    if (Platform.isIOS) {
      if (await canLaunch(whatsappWebURL)) {
        await launch(whatsappWebURL);
      } else {
        throw 'Could not launch $whatsappWebURL';
      }
    } else {
      if (await canLaunch(whatsappURL_android)) {
        await launch(whatsappURL_android);
      } else {
        throw 'Could not launch $whatsappURL_android';
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
