import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../car_game_page.dart';
import 'course_day_page.dart';

class CourseOverviewPage extends StatefulWidget {
  @override
  _CourseOverviewPageState createState() => _CourseOverviewPageState();
}

class _CourseOverviewPageState extends State<CourseOverviewPage> {
  final List<Map<String, String>> courseDays = [
    {"day": "Day 1", "title": "Introduction to Driving"},
    {"day": "Day 2", "title": "Pre-Driving Checks"},
    {"day": "Day 3", "title": "Basic Driving Techniques"},
    {"day": "Day 4", "title": "Steering Techniques"},
    {"day": "Day 5", "title": "Braking and Acceleration"},
    {"day": "Day 6", "title": "Gear Shifting"},
    {"day": "Day 7", "title": "Parking Techniques"},
    {"day": "Day 8", "title": "Lane Discipline"},
    {"day": "Day 9", "title": "Traffic Signals and Signs"},
    {"day": "Day 10", "title": "Night Driving"},
    {"day": "Day 11", "title": "Highway Driving"},
    {"day": "Day 12", "title": "City Driving"},
    {"day": "Day 13", "title": "Defensive Driving"},
    {"day": "Day 14", "title": "Emergency Situations"},
    {"day": "Day 15", "title": "Driving in Different Conditions"},
    {"day": "Day 16", "title": "Fuel Efficiency"},
    {"day": "Day 17", "title": "Road Etiquette"},
    {"day": "Day 18", "title": "Long-Distance Driving"},
    {"day": "Day 19", "title": "Vehicle Maintenance"},
    {"day": "Day 20", "title": "Legal Aspects"},
    {"day": "Day 21", "title": "Final Review and Practice"},
  ];

  late SharedPreferences _prefs;
  int _completedDay = 0;
  String _lastCompletedDate = '';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedDay = _prefs.getInt('completedDay') ?? 0;
      _lastCompletedDate = _prefs.getString('lastCompletedDate') ?? '';
    });
  }

  Future<void> _updateProgress(int day) async {
    final currentDate = DateTime.now().toIso8601String().split('T').first;
    await _prefs.setInt('completedDay', day);
    await _prefs.setString('lastCompletedDate', currentDate);
    setState(() {
      _completedDay = day;
      _lastCompletedDate = currentDate;
    });
  }

  bool _canAccessDay(int day) {
    final currentDate = DateTime.now().toIso8601String().split('T').first;
    return day == _completedDay + 1 && currentDate != _lastCompletedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white), // Change arrow color

        title: Text(
          '21 Day Driving School',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2,color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Course information')),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.withOpacity(0.1), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _completedDay / courseDays.length,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_completedDay} of ${courseDays.length} days completed',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Days list header
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  'Course Days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade700,
                  ),
                ),
              ),

              // List of days
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: courseDays.length,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isCompleted = day <= _completedDay;
                    final isUnlocked = day <= _completedDay + 1;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted ? Colors.green : Colors.blueAccent).withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: isUnlocked
                              ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDayPage(
                                  dayIndex: day,
                                  onComplete: () => _updateProgress(day),
                                ),
                              ),
                            );

                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 10),
                                      Text('Day $day completed!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade50,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Day circle
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted
                                        ? Colors.green
                                        : (isUnlocked ? Colors.blueAccent : Colors.grey.shade400),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isCompleted ? Colors.green : Colors.blueAccent).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      courseDays[index]["day"]!.split(' ')[1],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        courseDays[index]["title"]!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? Colors.black87 : Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            isCompleted
                                                ? Icons.check_circle
                                                : (isUnlocked ? Icons.play_circle_fill : Icons.lock),
                                            size: 16,
                                            color: isCompleted
                                                ? Colors.green
                                                : (isUnlocked ? Colors.blueAccent : Colors.grey),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            isCompleted
                                                ? 'Completed'
                                                : (isUnlocked ? 'Ready to start' : 'Locked'),
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : (isUnlocked ? Colors.blueAccent : Colors.grey),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (courseDays[index].containsKey("description") && courseDays[index]["description"] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            courseDays[index]["description"]!,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Status icon
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : (isUnlocked ? Icons.arrow_forward_ios : Icons.lock),
                                  color: isCompleted
                                      ? Colors.green
                                      : (isUnlocked ? Colors.blueAccent : Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarGamePage()),
            );
          },
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.videogame_asset),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}