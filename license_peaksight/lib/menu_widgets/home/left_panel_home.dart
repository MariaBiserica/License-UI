import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:license_peaksight/constants.dart';

class LeftPanelHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Constants.kPaddingHome / 2),
      margin: EdgeInsets.all(Constants.kPaddingHome), // Adds margin around the container
      decoration: BoxDecoration(
        color: Constants.panelBackground,
        borderRadius: BorderRadius.circular(Constants.borderRadius), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 20,
            offset: Offset(0, 10), // Changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: Constants.kPaddingHome),
          Text(
            'Quick Access',
            style: TextStyle(
              fontFamily: 'MOXABestine', 
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
          SizedBox(height: Constants.kPaddingHome),
          _buildStatsOverview(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Card(
      color: Constants.panelForeground,
      elevation: 3,
      margin: EdgeInsets.all(Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Constants.kPaddingHome / 2),
        child: Column(
          children: [
            Text(
              'Stats Overview',
              style: TextStyle(
                fontFamily: 'Rastaglion',
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            Divider(color: Colors.white54),
            _buildStatItem("Images Processed", "1234"),
            _buildStatItem("Tasks Completed", "112"),
            _buildStatItem("Tasks In Progress", "47"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(  // Makes the title flexible, wrapping text if needed
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Voguella',
                fontSize: 16,
                color: Colors.white
              ),
              overflow: TextOverflow.fade,  // Prevents text from overflowing
            ),
          ),
          SizedBox(width: 10), // Adds space between title and value
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Constants.panelForeground, // Slightly darker background for the value
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), // Shadow with some opacity
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1), // Position of shadow
                ),
              ],
            ),
            child: Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
          ),
        ],
      ),
    );
  }

}
