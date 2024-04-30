import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:license_peaksight/app_bar/custom_avatar.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/responsive_layout.dart';

List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
int _currentSelectedButton = 0;

class AppBarWidget extends StatefulWidget {
  final String? avatarUrl;

  AppBarWidget({this.avatarUrl});

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        User? user = snapshot.data;
        // Use the user's photo URL if available, otherwise use the avatar URL provided in the widget
        String avatarUrl = widget.avatarUrl ?? "images/profile.png"; // user?.photoURL ?? widget.avatarUrl ?? "images/profile.png";
        if (user?.photoURL != "" && user?.photoURL != null) {
          avatarUrl = user!.photoURL!;
        }

        return Container(
          color: Constants.purpleLight,
          child: Row(
            children: [
              if (ResponsiveLayout.isComputer(context))
                Container(
                  margin: EdgeInsets.all(Constants.kPadding),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 0),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    child: Image.asset("images/logo.png"),
                  ),
                )
              else
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  iconSize: 30,
                  color: Colors.white,
                  icon: Icon(Icons.menu),
                ),
              SizedBox(width: Constants.kPadding),
              Spacer(),
              if (ResponsiveLayout.isComputer(context))
                ..._buttonNames.map((name) => TextButton(
                  onPressed: () {
                    setState(() {
                      _currentSelectedButton = _buttonNames.indexOf(name);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(Constants.kPadding * 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(name, style: TextStyle(color: _currentSelectedButton == _buttonNames.indexOf(name) ? Colors.white : Colors.white60)),
                        Container(
                          margin: EdgeInsets.all(Constants.kPadding / 2),
                          width: 60,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: _currentSelectedButton == _buttonNames.indexOf(name)
                                ? LinearGradient(colors: [Constants.beginGradient, Constants.endGradient])
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList()
              else
                Padding(
                  padding: EdgeInsets.all(Constants.kPadding * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_buttonNames[_currentSelectedButton], style: TextStyle(color: Colors.white)),
                      Container(
                        margin: EdgeInsets.all(Constants.kPadding / 2),
                        width: 60,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Constants.beginGradient, Constants.endGradient]),
                        ),
                      ),
                    ],
                  ),
                ),
              Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Logout':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'Edit':
                      Navigator.pushNamed(context, '/edit');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(value: 'Edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                  PopupMenuItem(value: 'Logout', child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')))
                ],
                icon: Icon(Icons.settings, color: Colors.white, size: 30),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_none_outlined),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      backgroundColor: Colors.pink,
                      radius: 8,
                      child: Text("3", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              if (!ResponsiveLayout.isPhone(context))
                Container(
                  margin: EdgeInsets.all(Constants.kPadding),
                  height: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black45, offset: Offset(0, 0), spreadRadius: 1, blurRadius: 10),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Constants.endGradient,
                    radius: 30,
                    child: CustomAvatar(
                      imageUrl: avatarUrl,
                      fallbackAsset: "images/profile.png" // Specify a default local asset image
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
