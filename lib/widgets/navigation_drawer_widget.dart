import 'package:flutter/material.dart';
import 'package:tfg/globals/globalvariables.dart';

import 'package:tfg/screens/myrecepiesscreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg/screens/profilescreen.dart';

class NavigationDrawerWidget extends StatefulWidget {
  //final DrawerCallback callback;
  const NavigationDrawerWidget({Key? key, }) : super(key: key);

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  
  String urlImage = "";
  @override
  void initState() {
    super.initState();
    
   
    urlImage =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';
  }

  
  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser!;
    return Drawer(
      child: Material(
        color: const Color.fromRGBO(50, 75, 205, 1),
        child: ListView(
          children: <Widget>[
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                          radius: 30, backgroundImage: NetworkImage(urlImage)),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName!,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.email!,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildMenuItem(
                    text: 'Profile',
                    icon: Icons.people,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'My lists',
                    icon: Icons.playlist_add,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  const SizedBox(height: 16),
                  buildMenuItem(
                    text: 'My Recipies',
                    icon: Icons.fastfood_rounded,
                    onClicked: () => selectedItem(context, 2),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white70),
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Log Out',
                    icon: Icons.logout_rounded,
                    onClicked: () => selectedItem(context, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    //Navigator.of(context).pop();

    switch (index) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => const ProfilePageScreen(),
        ))
            .then((result) {
          if (result != null) {
            setState(() {});
          }
        });
        
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MyRecipes(),
        ));
        break;
      case 3:
        FirebaseAuth.instance.signOut();
        //FirebaseAuth.instance.currentUser!.delete();
        break;
    }
  }
}
