import 'package:flutter/material.dart';
import 'package:frontend/config/theme/color_schemes.g.dart';
import 'package:go_router/go_router.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: whiteColor, // Assuming 'whiteColor' is defined
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Center the avatar at the top
            Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: AssetImage('assets/profile_picture.jpg'),
              ),
            ),
            const SizedBox(height: 30.0), // Add some spacing
            // Text below the avatar
            Text(
              'Name Name',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24.0), // Increased space between text and card
            // Center the InkWell card horizontally
            Row(
              children: [
                Expanded( // Expand the card to full width
                  child: InkWell(
                    onTap: () {
                      context.go('/editinfo');
                      // Handle card tap (edit information)
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                      ),
                      padding: const EdgeInsets.all(8.0), // Add some padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align text left, icon right
                        children: [
                          Text(
                            'Edit Information',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold, // Adjust text color
                            ),
                          ),
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.grey, // Icon color
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Add more sections for different profile details here
          ],
        ),
      ),
    );
  }
}
