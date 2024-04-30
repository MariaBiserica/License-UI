import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/responsive_layout.dart';

List<String> _buttonNames = ["Overview", "Revenue", "Sales", "Control"];
int _currentSelectedButton= 0;

class AppBarWidget extends StatefulWidget {
  final String currentSection;
  final String? avatarUrl;

  AppBarWidget({required this.currentSection, this.avatarUrl});

  @override
  _AppBarWidgetState createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.purpleLight,
      child: Row(
        children: [
          if(ResponsiveLayout.isComputer(context))
            Container(margin: EdgeInsets.all(Constants.kPadding),
            height: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0,0),
                  spreadRadius: 1,
                  blurRadius: 10,),
              ],
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              // backgroundColor: Color.fromARGB(255, 168, 249, 212),
              radius: 30,
              child: Image.asset("images/logo.png"),
            ),
          ) else 
              IconButton(
                onPressed: (){
                  Scaffold.of(context).openDrawer();
                }, 
                iconSize: 30,
                color: Colors.white,
                icon: Icon(Icons.menu),
              ),
              SizedBox(
                width: Constants.kPadding,
              ),
              Spacer(),
              if(ResponsiveLayout.isComputer(context)) // If the screen is a computer, display the buttons
                ...List.generate(
                  _buttonNames.length, 
                  (index) => TextButton(
                    onPressed: (){
                      setState(() {
                      _currentSelectedButton = index;
                    });
                  }, 
                  child: Padding(
                    padding: EdgeInsets.all(Constants.kPadding*2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _buttonNames[index],
                          style: TextStyle(
                            color: _currentSelectedButton == index 
                            ? Colors.white 
                            : Colors.white60,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(Constants.kPadding/2),
                          width: 60,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: _currentSelectedButton == index
                            ? LinearGradient(
                              colors: [
                                Constants.beginGradient,
                                Constants.endGradient,
                              ],
                            )
                            : null,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(Constants.kPadding *2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _buttonNames[_currentSelectedButton],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.all(Constants.kPadding/2),
                          width: 60,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Constants.beginGradient,
                                Constants.endGradient,
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ),
            Spacer(),
            PopupMenuButton<String>( // Popup menu button for settings
              onSelected: (value) {
                switch (value) {
                  case 'Logout':
                    // Navigate to the login page
                    Navigator.pushReplacementNamed(context, '/login');
                    break;
                  case 'Edit':
                    // Navigate to the edit page
                    //Navigator.pushNamed(context, '/edit');
                    break;
                  default:
                    print("Not a valid selection");
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
              ],
              icon: Icon(Icons.settings, color: Colors.white, size: 30),
            ),
            Stack(children: [ // Stack to display the notification icon and the number of notifications
              IconButton(
                color: Colors.white,
                iconSize: 30,
                onPressed: () {},
                icon: Icon(Icons.notifications_none_outlined),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  backgroundColor: Colors.pink,
                  radius: 8,
                  child: Text(
                    "3",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if(!ResponsiveLayout.isPhone(context))
            Container(
              margin: EdgeInsets.all(Constants.kPadding),
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0,0),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Constants.endGradient,
                radius: 30,
                backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : AssetImage("images/profile.png") as ImageProvider,
              ),
            ),
        ],
      ),
    );
  }
}