import 'package:flutter/material.dart';

class PrayerDetailPage extends StatelessWidget {
  final String prayerName;
  final String prayerTime;

  PrayerDetailPage({required this.prayerName, required this.prayerTime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$prayerName Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$prayerName at $prayerTime',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Significance and Benefits of $prayerName:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Here you can add detailed information about the significance and benefits of performing the $prayerName prayer.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
