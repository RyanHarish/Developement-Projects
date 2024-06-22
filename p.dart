import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'dart:math';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  Map<String, String> prayerTimes = {};
  bool isLoading = true;
  String city = 'London';
  String country = 'UK';
  String currentDate = '';
  DateTime selectedDate = DateTime.now();
  late AnimationController _controller;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late String dailyQuote;

  final List<String> quotes = [
    "The best among you are those who have the best manners and character. - Prophet Muhammad (PBUH)",
    "Indeed, Allah is with the patient. - Quran 2:153",
    "And the Hereafter is better for you than the first [life]. - Quran 93:4",
    "Allah does not burden a soul beyond that it can bear... - Quran 2:286",
    "And whoever relies upon Allah – then He is sufficient for him. - Quran 65:3",
    "So remember Me; I will remember you. - Quran 2:152",
    "The most beloved of deeds to Allah are those that are most consistent, even if it is small. - Prophet Muhammad (PBUH)"
  ];

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
    dailyQuote = getRandomQuote();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Get current date and time
    var now = DateTime.now();
    currentDate = '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchPrayerTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedPrayerTimes = prefs.getString(
        'prayerTimes_${selectedDate.toIso8601String().split('T')[0]}');

    if (cachedPrayerTimes != null) {
      setState(() {
        prayerTimes = Map<String, String>.from(json.decode(cachedPrayerTimes));
        isLoading = false;
      });
    } else {
      try {
        var response = await Dio().get(
            'http://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2&date=${selectedDate.toIso8601String().split('T')[0]}');

        if (response.statusCode == 200) {
          final timings = response.data['data']['timings'];
          setState(() {
            prayerTimes = {
              'Fajr': timings['Fajr'],
              'Dhuhr': timings['Dhuhr'],
              'Asr': timings['Asr'],
              'Maghrib': timings['Maghrib'],
              'Isha': timings['Isha'],
            };
            isLoading = false;
          });
          await prefs.setString(
              'prayerTimes_${selectedDate.toIso8601String().split('T')[0]}',
              json.encode(prayerTimes));
          _schedulePrayerNotifications(prayerTimes);
        } else {
          throw Exception('Failed to load prayer times');
        }
      } catch (e) {
        print('Error fetching prayer times: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void refreshPrayerTimes() {
    setState(() {
      isLoading = true;
      dailyQuote = getRandomQuote();
    });
    fetchPrayerTimes();
  }

  Future<void> _showCityDialog() async {
    String newCity = city;
    String newCountry = country;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter City and Country'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    newCity = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'City',
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    newCountry = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Country',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  city = newCity;
                  country = newCountry;
                  isLoading = true;
                });
                fetchPrayerTimes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _schedulePrayerNotifications(Map<String, String> prayerTimes) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    for (var prayer in prayerTimes.entries) {
      var timeParts = prayer.value.split(':');
      var prayerTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      var notificationTime = _nextInstanceOfTime(prayerTime);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        prayer.key.hashCode,
        '${prayer.key} Time',
        'It is time for ${prayer.key} prayer.',
        notificationTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$prayer',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Icons.brightness_3;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.brightness_5;
      case 'Maghrib':
        return Icons.brightness_7;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  void _togglePrayerCompletion(String prayerName) {
    setState(() {
      bool currentValue = prayerTimes[prayerName] == 'Completed';
      prayerTimes[prayerName] = currentValue ? 'Pending' : 'Completed';
    });
  }

  Widget _buildPrayerTile(String prayerName, String prayerTime) {
    bool isCompleted = prayerTime == 'Completed';

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          _getPrayerIcon(prayerName),
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          prayerName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue, // Change to your desired color
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: $prayerTime',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600], // Change to your desired color
              ),
            ),
            SizedBox(height: 4),
            Text(
              'City: $city, Country: $country',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey, // Change to your desired color
              ),
            ),
          ],
        ),
        trailing: Checkbox(
          value: isCompleted,
          onChanged: (bool? value) {
            _togglePrayerCompletion(prayerName);
          },
        ),
        onTap: () {
          _togglePrayerCompletion(prayerName);
        },
        hoverColor: Colors.grey.withOpacity(0.1),
        focusColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    return Column(
      children: prayerTimes.keys
          .map((prayerName) =>
              _buildPrayerTile(prayerName, prayerTimes[prayerName]!))
          .toList(),
    );
  }

  Widget _buildPrayerTimesSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prayer Times:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          _buildPrayerTimesList(),
        ],
      ),
    );
  }

  Widget _buildDateAndActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            dailyQuote,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.orange, // Example of a warm color
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date: $currentDate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red, // Example of a warm color
              ),
            ),
            IconButton(
              onPressed: () => _showCityDialog(),
              icon: Icon(Icons.location_city),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBodyContent() {
    return isLoading
        ? _buildLoadingIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateAndActions(),
              _buildPrayerTimesSection(),
              _buildCalendar(),
            ],
          );
  }

  Widget _buildPrayerTimeTile(String prayerName, String prayerTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Change to your desired color
            ),
          ),
          Text(
            prayerTime,
            style: TextStyle(
              color: Colors.grey[600], // Change to your desired color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesLeftSide() {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prayer Times',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildPrayerTimeTile('Fajr', prayerTimes['Fajr'] ?? ''),
          _buildPrayerTimeTile('Dhuhr', prayerTimes['Dhuhr'] ?? ''),
          _buildPrayerTimeTile('Asr', prayerTimes['Asr'] ?? ''),
          _buildPrayerTimeTile('Maghrib', prayerTimes['Maghrib'] ?? ''),
          _buildPrayerTimeTile('Isha', prayerTimes['Isha'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildPrayerTimesLeftSide(),
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  isLoading = true;
                });
                fetchPrayerTimes();
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.red),
                holidayTextStyle: TextStyle(color: Colors.green),
                outsideDaysVisible:
                    false, // Hide days outside the current month
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
        actions: [
          IconButton(
            onPressed: () => refreshPrayerTimes(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: _buildBodyContent(),
      ),
    );
  }

  String getRandomQuote() {
    final Random random = Random();
    return quotes[random.nextInt(quotes.length)];
  }
}
