import 'package:flutter/material.dart';
import 'package:tfg/globals/globalvariables.dart';
import 'package:tfg/screens/myrecepiesscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg/screens/profilescreen.dart';

class NavigationDrawerWidget extends StatefulWidget {
  
  const NavigationDrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Drawer(
      child: Scaffold(
        backgroundColor: Colors.teal,
        body: ListView(
          children: <Widget>[
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ((user.photoURL) != null)
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user.photoURL!))
                          : const Icon(
                              Icons.account_circle_rounded,
                              size: 50.0,
                              color: Colors.white,
                            ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName!,
                            style: const TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'Heebo'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email!,
                            style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Heebo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40,),
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
      leading: Icon(icon, color: color, size: 30.0),
      title: Text(text, style: const TextStyle(color: color, fontFamily: "Heebo", fontSize: 25)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
   

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
       
        break;
    }
  }
}
