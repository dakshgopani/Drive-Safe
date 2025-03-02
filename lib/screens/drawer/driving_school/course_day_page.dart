import 'package:flutter/material.dart';
import 'quiz_page.dart';

class CourseDayPage extends StatelessWidget {
  final int dayIndex;
  final VoidCallback onComplete;

  CourseDayPage({required this.dayIndex, required this.onComplete});

  final List<Map<String, dynamic>> courseContent = [
    {
      'title': 'Introduction to Driving',
      'content': 'Driving is a crucial life skill that requires patience, practice, and knowledge of road rules. Understanding vehicle controls such as the steering wheel, accelerator, brake, and clutch is essential for safe driving.',
      'tips': [
        'Always wear your seatbelt before starting the car.',
        'Adjust your seat, mirrors, and steering wheel for comfort and visibility.',
        'Keep both hands on the steering wheel in the 9 and 3 o’clock position.',
        'Follow traffic rules and never drive without a valid license.',
        'Stay calm and avoid distractions like mobile phones while driving.'
      ]
    },
    {
      'title': 'Pre-Driving Checks',
      'content': 'Before starting a drive, it is essential to check tire pressure, brakes, headlights, indicators, and fuel levels to ensure vehicle safety.',
      'tips': [
        'Check the fuel level and tire pressure before starting.',
        'Ensure mirrors are adjusted for clear rear and side view.',
        'Test the brakes and handbrake before moving.',
        'Check if all lights and indicators are working properly.',
        'Keep your registration, insurance, and driving license handy.'
      ]
    },
    {
      'title': 'Basic Driving Techniques',
      'content': 'Starting and stopping smoothly, controlling speed, and maintaining balance are key elements of safe driving.',
      'tips': [
        'Always accelerate gradually to avoid jerks.',
        'Use the brake gently instead of stopping suddenly.',
        'Maintain a safe distance from the vehicle ahead.',
        'Keep both hands on the steering wheel for control.',
        'Observe traffic around you using mirrors frequently.'
      ]
    },
    {
      'title': 'Steering Techniques',
      'content': 'Steering is fundamental to controlling the car effectively. Proper hand positioning and smooth turning ensure better vehicle handling.',
      'tips': [
        'Hold the steering wheel at 9 and 3 o’clock for better control.',
        'Avoid sudden jerky movements while turning.',
        'Use the push-pull method for turning the wheel.',
        'Keep your focus ahead while turning, not just on the wheel.',
        'Do not cross hands while steering.'
      ]
    },
    {
      'title': 'Braking and Acceleration',
      'content': 'Braking and accelerating smoothly can enhance vehicle control and reduce wear and tear.',
      'tips': [
        'Apply the brake gradually rather than suddenly.',
        'Use engine braking in manual cars while slowing down.',
        'Accelerate smoothly, especially in traffic.',
        'Do not keep your foot on the brake pedal while driving.',
        'Avoid excessive braking unless necessary.'
      ]
    },
    {
      'title': 'Gear Shifting',
      'content': 'Understanding gear shifting is essential, especially for manual vehicles. Proper gear use improves fuel efficiency and vehicle performance.',
      'tips': [
        'Shift gears smoothly and at the right RPM.',
        'Never rest your hand on the gear lever while driving.',
        'Use the clutch properly to avoid engine damage.',
        'Downshift gradually while slowing down.',
        'In automatic cars, use "D" mode for regular driving.'
      ]
    },
    {
      'title': 'Parking Techniques',
      'content': 'Parking correctly prevents damage to your car and ensures other vehicles have enough space.',
      'tips': [
        'Use side mirrors and reverse cameras while parking.',
        'Turn the steering wheel completely for tight spots.',
        'Park within the designated parking lines.',
        'Use the handbrake when parking on slopes.',
        'Avoid blocking entryways or other vehicles.'
      ]
    },
    {
      'title': 'Lane Discipline',
      'content': 'Maintaining lane discipline improves traffic flow and reduces accidents.',
      'tips': [
        'Stick to your lane and avoid sudden lane changes.',
        'Use indicators before changing lanes.',
        'Overtake only from the right on Indian roads.',
        'Do not drive in the wrong direction on one-way roads.',
        'Stay in the left lane if driving slowly.'
      ]
    },
    {
      'title': 'Traffic Signals and Signs',
      'content': 'Traffic signals and road signs guide drivers and ensure safe road usage.',
      'tips': [
        'Always stop at a red signal.',
        'Follow speed limit signs for safety.',
        'Pay attention to pedestrian crossings.',
        'Yield the right-of-way where required.',
        'Do not ignore stop and warning signs.'
      ]
    },
    {
      'title': 'Night Driving',
      'content': 'Driving at night requires extra caution due to reduced visibility.',
      'tips': [
        'Use low beams in city driving, high beams on highways.',
        'Avoid looking directly at oncoming headlights.',
        'Drive slower than usual at night.',
        'Keep your windshield clean to reduce glare.',
        'Ensure your tail lights are functioning properly.'
      ]
    },
    {
      'title': 'Highway Driving',
      'content': 'Highway driving differs from city driving due to higher speeds and longer distances.',
      'tips': [
        'Maintain a consistent speed and use cruise control if available.',
        'Keep a safe following distance.',
        'Use indicators before overtaking.',
        'Stay in your lane and do not drive on the shoulder.',
        'Check fuel levels before long trips.'
      ]
    },
    {
      'title': 'City Driving',
      'content': 'City driving involves navigating traffic, signals, and pedestrians.',
      'tips': [
        'Be prepared for frequent stops and lane changes.',
        'Watch out for pedestrians and cyclists.',
        'Keep an eye on public transport vehicles.',
        'Avoid honking unnecessarily.',
        'Be patient in heavy traffic.'
      ]
    },
    {
      'title': 'Defensive Driving',
      'content': 'Defensive driving helps avoid accidents and handle unpredictable drivers.',
      'tips': [
        'Always anticipate the actions of other drivers.',
        'Keep a safe distance from all vehicles.',
        'Do not engage with aggressive drivers.',
        'Stay alert and avoid distractions.',
        'Follow speed limits strictly.'
      ]
    },
    {
      'title': 'Emergency Situations',
      'content': 'Knowing how to react in emergencies can save lives.',
      'tips': [
        'Stay calm in case of an accident.',
        'Call emergency services immediately.',
        'Carry a basic first-aid kit.',
        'Keep emergency contact numbers saved.',
        'Learn how to use a fire extinguisher in cars.'
      ]
    },
    {
      'title': 'Driving in Different Conditions',
      'content': 'Weather conditions like rain, fog, or extreme heat affect driving.',
      'tips': [
        'Use fog lights in low visibility.',
        'Avoid waterlogged roads during heavy rain.',
        'Drive slower in slippery conditions.',
        'Keep wipers in good condition.',
        'Check tire pressure in extreme temperatures.'
      ]
    },
    {
      'title': 'Fuel Efficiency',
      'content': 'Fuel-efficient driving saves money and is eco-friendly.',
      'tips': [
        'Maintain a steady speed.',
        'Avoid sudden acceleration and braking.',
        'Reduce excess weight in the car.',
        'Keep tires properly inflated.',
        'Turn off the engine in long stops.'
      ]
    },
    {
      'title': 'Road Etiquette',
      'content': 'Good road manners ensure a smooth traffic flow.',
      'tips': [
        'Give way to emergency vehicles.',
        'Do not honk unnecessarily.',
        'Do not block intersections.',
        'Let pedestrians cross safely.',
        'Respect all road users.'
      ]
    },
    {
      'title': 'Long-Distance Driving',
      'content': 'Driving long distances requires endurance and planning.',
      'tips': [
        'Take breaks every 2-3 hours.',
        'Stay hydrated but avoid excessive caffeine.',
        'Plan your route in advance.',
        'Check tire pressure before leaving.',
        'Avoid driving when fatigued.'
      ]
    },
    {
      'title': 'Vehicle Maintenance',
      'content': 'A well-maintained car ensures safety and longevity.',
      'tips': [
        'Check engine oil levels regularly.',
        'Inspect tires for wear and tear.',
        'Keep brakes in good condition.',
        'Service your car as per schedule.',
        'Keep headlights and wipers clean.'
      ]
    },
    {
      'title': 'Legal Aspects',
      'content': 'Understanding driving laws helps avoid fines.',
      'tips': [
        'Always carry your driving license.',
        'Follow speed limits to avoid penalties.',
        'Do not drink and drive.',
        'Renew insurance on time.',
        'Follow lane discipline to avoid fines.'
      ]
    }
  ];


  @override
  Widget build(BuildContext context) {
    final dayContent = courseContent[dayIndex - 1];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dayContent['title'],
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lesson bookmarked!')),
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
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day indicator
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.5))
                  ),
                  child: Text(
                    'DAY ${dayIndex}',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // Main content card
                Card(
                  elevation: 8,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with decorative underline
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayContent['title'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Main content
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dayContent['content'],
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Tips & Tricks section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tips & Tricks',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ...dayContent['tips'].map<Widget>((tip) =>
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 12.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            tip,
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Quiz button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                              elevation: 5,
                              shadowColor: Colors.blueAccent.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              // Navigate to the quiz
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizPage(dayIndex: dayIndex),
                                ),
                              );

                              if (result == true) {
                                onComplete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green),
                                        SizedBox(width: 10),
                                        Text('Quiz passed! You can proceed.'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green.shade50,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red),
                                        SizedBox(width: 10),
                                        Text('Quiz failed! Try again.'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red.shade50,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.quiz),
                                SizedBox(width: 10),
                                Text('Take Quiz'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}