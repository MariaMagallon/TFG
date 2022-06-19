import 'package:flutter/material.dart';

Future<void> showMyDialog(
      BuildContext context, String ptitle, String pcontent) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ptitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(pcontent),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }