import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/drawer/curve_clipper.dart';
import 'package:license_peaksight/responsive_layout.dart';

class DrawerPage extends StatefulWidget {
  final Function(String) onSectionSelected;

  DrawerPage({required this.onSectionSelected}) {
    print("Callback set: $onSectionSelected");
  }

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class ButtonsInfo {
  String title;
  IconData icon;

  ButtonsInfo({required this.title, required this.icon});
}

int _currentIndex = 0;

List<ButtonsInfo> _buttonNames = [
  ButtonsInfo(title: 'Home', icon: Icons.dashboard),
  ButtonsInfo(title: 'Image Quality Assessment', icon: Icons.assessment),
  ButtonsInfo(title: 'Image Modifier', icon: Icons.tune),
  ButtonsInfo(title: 'Batch Processing', icon: Icons.batch_prediction),
  ButtonsInfo(title: 'Help & Documentation', icon: Icons.help_outline),
];

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ResponsiveLayout.isComputer(context) ? CurveClipper() : null,
      child: Drawer(
        child: Container(
          color: Theme.of(context).canvasColor,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(5.0, 1.0),
                            blurRadius: 2.0,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ],
                        fontFamily: 'MenuFont',
                        fontSize: 55,
                      ),
                    ),
                    trailing: ResponsiveLayout.isComputer(context)
                        ? null
                        : IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                  ),
                  ...List.generate(
                    _buttonNames.length,
                    (index) => Column(
                      children: [
                        Container(
                          decoration: index == _currentIndex
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Constants.beginGradient.withOpacity(0.9),
                                      Constants.endGradient.withOpacity(0.9),
                                    ],
                                  ),
                                )
                              : null,
                          child: ListTile(
                            title: Text(
                              _buttonNames[index].title,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Rastaglion',
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Color.fromARGB(150, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.all(Constants.kPadding),
                              child: Icon(
                                _buttonNames[index].icon,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                              });
                              widget.onSectionSelected(_buttonNames[index].title);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                          thickness: 0.1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
