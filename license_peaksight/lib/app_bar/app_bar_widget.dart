import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:license_peaksight/app_bar/custom_avatar.dart';
import 'package:license_peaksight/app_bar/notification_service.dart';
import 'package:license_peaksight/authentication/edit_page.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/responsive_layout.dart';

int _currentSelectedButton = 0;

class AppBarWidget extends StatefulWidget {
  final String? avatarUrl;
  final List<NotificationCustom> notifications; // Pass notifications to the AppBarWidget
  final Function(NotificationCustom) onRestore; // Callback to restore task
  final VoidCallback onClearNotifications; // Callback to clear notifications

  AppBarWidget({
    this.avatarUrl,
    required this.notifications,
    required this.onRestore,
    required this.onClearNotifications,
  });

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        User? user = snapshot.data;
        // Use the user's photo URL if available, otherwise use the avatar URL provided in the widget
        String avatarUrl = widget.avatarUrl ?? "images/profile.png";
        if (user?.photoURL != "" && user?.photoURL != null) {
          avatarUrl = user!.photoURL!;
        }

        return Container(
          color: Constants.purpleLight,
          child: Row(
            children: [
              SizedBox(width: Constants.kPadding),
              if (ResponsiveLayout.isComputer(context))
                Row(
                  children: [
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
                    ),
                    SizedBox(width: 10),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildWelcomeMessage("Welcome back!");
                        } else if (snapshot.hasError) {
                          return _buildWelcomeMessage("Error loading username");
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return _buildWelcomeMessage("Welcome back!");
                        } else {
                          var userDoc = snapshot.data!;
                          _username = userDoc['username'];
                          return _buildWelcomeMessage("Welcome back, $_username!");
                        }
                      },
                    ),
                  ],
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
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'Logout':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'Edit':
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(
                              email: user.email!,
                              username: userDoc['username'],
                              avatarUrl: user.photoURL,
                            ),
                          ),
                        );
                      }
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
                    onPressed: () {
                      _showNotificationsDialog(context);
                    },
                    icon: Icon(Icons.notifications_none_outlined),
                    color: Colors.white,
                    iconSize: 30,
                  ),
                  if (widget.notifications.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CircleAvatar(
                        backgroundColor: Colors.pink,
                        radius: 8,
                        child: Text(
                          "${widget.notifications.length}",
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
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
                      fallbackAsset: "images/profile.png", // Specify a default local asset image
                    ),
                  ),
                ),
              SizedBox(width: Constants.kPadding),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage(String message) {
    return CustomPaint(
      painter: SpeechBubblePainter(),
      child: Container(
        padding: EdgeInsets.fromLTRB(25, 8, 15, 8),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'IndieFlower',
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notifications"),
          content: Container(
            width: double.minPositive, // Ensures the dialog is only as wide as the content needs it to be
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                var notification = widget.notifications[index];
                return ListTile(
                  title: Text(notification.message),
                  trailing: IconButton(
                    icon: Icon(Icons.restore),
                    onPressed: () {
                      widget.onRestore(notification);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                widget.onClearNotifications();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Clear Notifications'),
            ),
          ],
        );
      },
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 246, 2, 96).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(20, 10)
      ..lineTo(20, 10)
      ..arcToPoint(Offset(size.width - 190, 0), radius: Radius.circular(10))
      // Draw top side and top-right rounded corner
      ..lineTo(size.width - 10, 0)
      ..arcToPoint(Offset(size.width, 10), radius: Radius.circular(10))
      // Draw right side and bottom-right rounded corner
      ..lineTo(size.width, size.height - 10)
      ..arcToPoint(Offset(size.width - 10, size.height), radius: Radius.circular(10))
      // Draw bottom side
      ..lineTo(30, size.height)
      ..arcToPoint(Offset(20, size.height - 10), radius: Radius.circular(10))
      // Draw left side and close the path
      ..lineTo(10, 20)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
