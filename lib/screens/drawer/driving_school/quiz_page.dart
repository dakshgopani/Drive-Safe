import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Optional: For animations (add to pubspec.yaml)
class QuizPage extends StatefulWidget {
  final int dayIndex;
  QuizPage({required this.dayIndex});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  
  final List<Map<String, dynamic>> day_1 = [
    {
      'question': 'What is the first step before starting the car?',
      'options': ['Turn on headlights', 'Adjust mirrors and seat', 'Check fuel level', 'Press accelerator'],
      'answer': 'Adjust mirrors and seat'
    },
    {
      'question': 'Which foot should you use for the brake pedal?',
      'options': ['Right foot', 'Left foot', 'Both feet', 'Any foot'],
      'answer': 'Right foot'
    },
    {
      'question': 'What is the main purpose of defensive driving?',
      'options': ['Drive as fast as possible', 'Avoid accidents by anticipating dangers', 'Ignore traffic rules', 'Race other vehicles'],
      'answer': 'Avoid accidents by anticipating dangers'
    },
    {
      'question': 'What is the safest hand position on the steering wheel?',
      'options': ['10 and 2', '9 and 3', '12 and 6', '11 and 1'],
      'answer': '9 and 3'
    },
    {
      'question': 'What does the clutch do in a manual car?',
      'options': ['Stops the engine', 'Helps shift gears', 'Accelerates the car', 'Controls the wipers'],
      'answer': 'Helps shift gears'
    },
    {
      'question': 'Why should you avoid distractions while driving?',
      'options': ['It looks unprofessional', 'It reduces reaction time', 'It saves fuel', 'It increases speed'],
      'answer': 'It reduces reaction time'
    },
    {
      'question': 'What does ABS stand for in a car?',
      'options': ['Automatic Braking System', 'Anti-lock Braking System', 'Advanced Braking System', 'Anti-slip Braking System'],
      'answer': 'Anti-lock Braking System'
    },
    {
      'question': 'When should you check your mirrors while driving?',
      'options': ['Only before parking', 'Every few seconds', 'Only when changing lanes', 'Never'],
      'answer': 'Every few seconds'
    },
    {
      'question': 'Why should you keep a safe distance from the car ahead?',
      'options': ['To increase fuel efficiency', 'To allow for reaction time', 'To slow down traffic', 'To reduce wear on tires'],
      'answer': 'To allow for reaction time'
    },
    {
      'question': 'What is the most important rule for safe driving?',
      'options': ['Drive fast to avoid traffic', 'Always follow traffic rules', 'Ignore other drivers', 'Use your phone for navigation'],
      'answer': 'Always follow traffic rules'
    }
  ];

  final List<Map<String, dynamic>> day_2 = [
    {
      'question': 'Which of these should you check before driving?',
      'options': ['Brakes', 'Mirrors', 'Seat Position', 'All of the above'],
      'answer': 'All of the above'
    },
    {
      'question': 'What should you check on your tires before driving?',
      'options': ['Color', 'Size', 'Pressure and tread', 'Brand'],
      'answer': 'Pressure and tread'
    },
    {
      'question': 'What should you do if a warning light appears on the dashboard?',
      'options': ['Ignore it', 'Check the manual', 'Stop immediately', 'Rev the engine'],
      'answer': 'Check the manual'
    },
    {
      'question': 'What does a red oil light indicate?',
      'options': ['Low fuel', 'Engine overheating', 'Low oil pressure', 'Battery failure'],
      'answer': 'Low oil pressure'
    },
    {
      'question': 'How often should you check your brake fluid?',
      'options': ['Once a month', 'Once a year', 'Only during servicing', 'Every day'],
      'answer': 'Once a month'
    },
    {
      'question': 'What does it mean if your tire pressure is low?',
      'options': ['Better grip', 'Increased fuel efficiency', 'Reduced control and fuel efficiency', 'Improved braking'],
      'answer': 'Reduced control and fuel efficiency'
    },
    {
      'question': 'Why is it important to adjust your seat before driving?',
      'options': ['To reach the pedals comfortably', 'To look stylish', 'To keep passengers comfortable', 'To increase car speed'],
      'answer': 'To reach the pedals comfortably'
    },
    {
      'question': 'When should you check your car’s battery?',
      'options': ['Once a week', 'Before long trips', 'Every day', 'Only when replacing it'],
      'answer': 'Before long trips'
    },
    {
      'question': 'What should be done if your car’s headlights are dim?',
      'options': ['Replace the bulbs', 'Ignore it', 'Turn on high beams', 'Drive with hazard lights'],
      'answer': 'Replace the bulbs'
    },
    {
      'question': 'What should you do if the brake pedal feels soft?',
      'options': ['Pump the brakes', 'Check brake fluid levels', 'Drive faster', 'Ignore it'],
      'answer': 'Check brake fluid levels'
    }
  ];

  final List<Map<String, dynamic>> day_3 = [
    {
      'question': 'What should you do before starting the engine?',
      'options': ['Fasten your seatbelt', 'Adjust your seat', 'Check your mirrors', 'All of the above'],
      'answer': 'All of the above'
    },
    {
      'question': 'How should you accelerate from a stop?',
      'options': ['Press the accelerator hard', 'Gradually increase speed', 'Keep pressing the brake', 'Rev the engine before moving'],
      'answer': 'Gradually increase speed'
    },
    {
      'question': 'What should you do when coming to a stop?',
      'options': ['Slam on the brakes', 'Gradually slow down', 'Shift to neutral', 'Use the handbrake only'],
      'answer': 'Gradually slow down'
    },
    {
      'question': 'Which technique is used for smooth braking?',
      'options': ['Pulse braking', 'Sudden braking', 'Engine braking', 'No braking'],
      'answer': 'Engine braking'
    },
    {
      'question': 'Why should you keep both hands on the steering wheel?',
      'options': ['To look professional', 'To maintain better control', 'To show confidence', 'To signal to other drivers'],
      'answer': 'To maintain better control'
    },
    {
      'question': 'What is the purpose of checking blind spots?',
      'options': ['To see pedestrians', 'To look for hidden vehicles', 'To check road signs', 'To check for potholes'],
      'answer': 'To look for hidden vehicles'
    },
    {
      'question': 'What should you do if your car starts skidding?',
      'options': ['Brake hard', 'Turn in the direction of the skid', 'Turn opposite to the skid', 'Accelerate immediately'],
      'answer': 'Turn in the direction of the skid'
    },
    {
      'question': 'Why is it important to keep a safe following distance?',
      'options': ['To allow time to react', 'To make room for overtaking', 'To save fuel', 'To avoid traffic fines'],
      'answer': 'To allow time to react'
    },
    {
      'question': 'What should you do before making a turn?',
      'options': ['Speed up', 'Use turn signals', 'Ignore the rearview mirror', 'Look only straight ahead'],
      'answer': 'Use turn signals'
    },
    {
      'question': 'What is the recommended stopping distance at 50 km/h?',
      'options': ['10 meters', '20 meters', '30 meters', '40 meters'],
      'answer': '30 meters'
    }
  ];

  final List<Map<String, dynamic>> day_4 = [
    {
      'question': 'What is the recommended hand position on the steering wheel?',
      'options': ['10 and 2', '9 and 3', '12 and 6', '8 and 4'],
      'answer': '9 and 3'
    },
    {
      'question': 'Which steering technique is considered the safest?',
      'options': ['Hand-over-hand', 'One-hand steering', 'Push-pull method', 'Using just fingers'],
      'answer': 'Push-pull method'
    },
    {
      'question': 'Why should you avoid sudden jerky movements while steering?',
      'options': ['To improve speed', 'To avoid loss of control', 'To save fuel', 'To make sharper turns'],
      'answer': 'To avoid loss of control'
    },
    {
      'question': 'What should you do when making a sharp turn?',
      'options': ['Increase speed', 'Brake hard', 'Turn smoothly and gradually', 'Turn the wheel as fast as possible'],
      'answer': 'Turn smoothly and gradually'
    },
    {
      'question': 'What happens if you cross your hands while steering?',
      'options': ['Better control', 'Loss of control', 'Faster turning', 'Better grip'],
      'answer': 'Loss of control'
    },
    {
      'question': 'Why should you keep your eyes on the road while steering?',
      'options': ['To maintain direction', 'To check the dashboard', 'To look for speed signs', 'To see other drivers'],
      'answer': 'To maintain direction'
    },
    {
      'question': 'When should you start turning the steering wheel for a curve?',
      'options': ['Midway through the turn', 'Before reaching the turn', 'After completing the turn', 'At full speed'],
      'answer': 'Before reaching the turn'
    },
    {
      'question': 'How can you prevent oversteering?',
      'options': ['Turn quickly', 'Use minimal steering input', 'Brake hard', 'Steer with one hand'],
      'answer': 'Use minimal steering input'
    },
    {
      'question': 'Why is the push-pull method recommended for turning?',
      'options': ['It allows smoother turns', 'It increases speed', 'It improves acceleration', 'It is used in racing'],
      'answer': 'It allows smoother turns'
    },
    {
      'question': 'How can you improve steering control?',
      'options': ['Drive faster', 'Keep both hands on the wheel', 'Use only one hand', 'Ignore road conditions'],
      'answer': 'Keep both hands on the wheel'
    }
  ];

  final List<Map<String, dynamic>> day_5 = [
    {
      'question': 'What is the proper way to apply the brakes?',
      'options': ['Suddenly press hard', 'Gradually apply pressure', 'Press and release quickly', 'Use only the handbrake'],
      'answer': 'Gradually apply pressure'
    },
    {
      'question': 'Why should you avoid braking too hard?',
      'options': ['It saves fuel', 'It prevents skidding', 'It makes the car faster', 'It improves tire pressure'],
      'answer': 'It prevents skidding'
    },
    {
      'question': 'When should you apply the handbrake?',
      'options': ['While driving', 'Only when parking', 'At every stop', 'Only on highways'],
      'answer': 'Only when parking'
    },
    {
      'question': 'What is engine braking?',
      'options': ['Using lower gears to slow down', 'Turning off the engine', 'Braking with the handbrake', 'Pressing the clutch while braking'],
      'answer': 'Using lower gears to slow down'
    },
    {
      'question': 'How does braking distance change with speed?',
      'options': ['It stays the same', 'It decreases', 'It increases', 'It becomes zero'],
      'answer': 'It increases'
    },
    {
      'question': 'What should you do if brakes fail?',
      'options': ['Press the brake harder', 'Pump the brake pedal', 'Accelerate', 'Turn off the engine'],
      'answer': 'Pump the brake pedal'
    },
    {
      'question': 'Why should you avoid resting your foot on the brake pedal?',
      'options': ['It increases braking power', 'It causes brake wear', 'It helps maintain speed', 'It improves acceleration'],
      'answer': 'It causes brake wear'
    },
    {
      'question': 'What is threshold braking?',
      'options': ['Braking just before skidding', 'Pressing the brake fully', 'Using handbrake while braking', 'Not using brakes at all'],
      'answer': 'Braking just before skidding'
    },
    {
      'question': 'What should you do if your car skids while braking?',
      'options': ['Let go of the brake', 'Press harder on the brake', 'Turn opposite to the skid', 'Accelerate'],
      'answer': 'Let go of the brake'
    },
    {
      'question': 'Which system helps prevent wheels from locking during braking?',
      'options': ['ABS', 'EBS', 'ESP', 'TCS'],
      'answer': 'ABS'
    }
  ];

  final List<Map<String, dynamic>> day_6 = [
    {
      'question': 'What is the purpose of gear shifting?',
      'options': ['To control speed and power', 'To improve air conditioning', 'To activate headlights', 'To engage handbrake'],
      'answer': 'To control speed and power'
    },
    {
      'question': 'When should you shift to a higher gear?',
      'options': ['At high RPM', 'At low speed', 'When turning', 'When reversing'],
      'answer': 'At high RPM'
    },
    {
      'question': 'What happens if you shift to a lower gear at high speed?',
      'options': ['Increases fuel efficiency', 'Reduces braking distance', 'Can damage the engine', 'Increases acceleration'],
      'answer': 'Can damage the engine'
    },
    {
      'question': 'How should you shift gears smoothly?',
      'options': ['Press clutch fully and shift gradually', 'Shift quickly without clutch', 'Press accelerator while shifting', 'Use only handbrake'],
      'answer': 'Press clutch fully and shift gradually'
    },
    {
      'question': 'What is the role of the clutch in manual cars?',
      'options': ['To change gears', 'To stop the car', 'To increase fuel efficiency', 'To control wipers'],
      'answer': 'To change gears'
    },
    {
      'question': 'Why should you not rest your hand on the gear lever?',
      'options': ['It looks unprofessional', 'It wears out gearbox components', 'It makes shifting faster', 'It improves grip'],
      'answer': 'It wears out gearbox components'
    },
    {
      'question': 'What is double clutching?',
      'options': ['Using clutch twice per shift', 'Shifting without clutch', 'Holding the clutch while driving', 'Skipping gears while shifting'],
      'answer': 'Using clutch twice per shift'
    },
    {
      'question': 'How does skipping gears affect driving?',
      'options': ['Saves fuel', 'Damages transmission', 'Improves speed', 'Reduces braking distance'],
      'answer': 'Damages transmission'
    },
    {
      'question': 'When should you downshift?',
      'options': ['When slowing down', 'At high speed', 'When parking', 'When accelerating'],
      'answer': 'When slowing down'
    },
    {
      'question': 'Which gear should you use for hill climbing?',
      'options': ['First or second gear', 'Neutral', 'Fifth gear', 'Reverse'],
      'answer': 'First or second gear'
    }
  ];
  final List<Map<String, dynamic>> day_7 = [
    {
      'question': 'What is the safest way to park on a slope?',
      'options': ['Use the handbrake', 'Turn wheels towards the curb', 'Leave the car in neutral', 'Both A and B'],
      'answer': 'Both A and B'
    },
    {
      'question': 'When parallel parking, what is the first step?',
      'options': ['Turn the wheel fully', 'Align with the parked car', 'Reverse immediately', 'Speed up'],
      'answer': 'Align with the parked car'
    },
    {
      'question': 'What should you check before exiting a parked car?',
      'options': ['Your seatbelt', 'Oncoming traffic', 'Tire pressure', 'Fuel level'],
      'answer': 'Oncoming traffic'
    },
    {
      'question': 'Why should you avoid parking near intersections?',
      'options': ['It’s illegal', 'It blocks visibility', 'It causes traffic congestion', 'All of the above'],
      'answer': 'All of the above'
    },
    {
      'question': 'What is the best way to park in a tight space?',
      'options': ['Move in quickly', 'Use mirrors and go slowly', 'Turn off parking sensors', 'Ignore surroundings'],
      'answer': 'Use mirrors and go slowly'
    },
    {
      'question': 'How far should your car be from the curb when parallel parked?',
      'options': ['10 cm', '30 cm', '50 cm', '1 meter'],
      'answer': '30 cm'
    },
    {
      'question': 'Which gear should you use when parking downhill with a manual car?',
      'options': ['Neutral', 'Reverse', 'First gear', 'Fifth gear'],
      'answer': 'Reverse'
    },
    {
      'question': 'What should you do when parking in a crowded parking lot?',
      'options': ['Look for the closest spot', 'Check surroundings and go slowly', 'Park as fast as possible', 'Ignore other cars'],
      'answer': 'Check surroundings and go slowly'
    },
    {
      'question': 'Why is it important to use parking sensors or cameras?',
      'options': ['To listen to beeping sounds', 'To see blind spots', 'To reduce parking time', 'To avoid scratches'],
      'answer': 'To see blind spots'
    },
    {
      'question': 'What should you do before reversing out of a parking spot?',
      'options': ['Accelerate quickly', 'Check mirrors and blind spots', 'Honk loudly', 'Reverse without looking'],
      'answer': 'Check mirrors and blind spots'
    }
  ];

  final List<Map<String, dynamic>> day_8 = [
    {
      'question': 'Why is lane discipline important?',
      'options': ['To reduce accidents', 'To increase traffic speed', 'To let others overtake', 'To slow down traffic'],
      'answer': 'To reduce accidents'
    },
    {
      'question': 'Which lane should slow-moving vehicles use?',
      'options': ['Leftmost lane', 'Middle lane', 'Rightmost lane', 'Any lane'],
      'answer': 'Leftmost lane'
    },
    {
      'question': 'When changing lanes, what should you do first?',
      'options': ['Check mirrors and blind spots', 'Speed up', 'Turn the wheel quickly', 'Honk'],
      'answer': 'Check mirrors and blind spots'
    },
    {
      'question': 'What is the purpose of lane markings?',
      'options': ['To separate lanes', 'To make roads look good', 'To allow random lane changes', 'To guide pedestrians'],
      'answer': 'To separate lanes'
    },
    {
      'question': 'When is it safe to change lanes?',
      'options': ['Whenever you feel like it', 'When there is enough space and after signaling', 'Immediately after overtaking', 'When others are changing lanes'],
      'answer': 'When there is enough space and after signaling'
    },
    {
      'question': 'Which lane is generally used for overtaking?',
      'options': ['Left lane', 'Middle lane', 'Right lane', 'Any lane'],
      'answer': 'Right lane'
    },
    {
      'question': 'What should you do if another driver is tailgating you?',
      'options': ['Brake suddenly', 'Switch lanes if possible', 'Speed up', 'Ignore them'],
      'answer': 'Switch lanes if possible'
    },
    {
      'question': 'What does a solid white line between lanes indicate?',
      'options': ['Passing allowed', 'Lane change prohibited', 'Pedestrian crossing', 'Bus lane'],
      'answer': 'Lane change prohibited'
    },
    {
      'question': 'What is the safest way to merge into highway traffic?',
      'options': ['Stop and wait for an opening', 'Match the speed of traffic and merge smoothly', 'Merge quickly without checking', 'Use hazard lights'],
      'answer': 'Match the speed of traffic and merge smoothly'
    },
    {
      'question': 'What should you do if you accidentally enter the wrong lane?',
      'options': ['Immediately change back', 'Continue and adjust safely', 'Stop and reverse', 'Honk at others'],
      'answer': 'Continue and adjust safely'
    }
  ];
  final List<Map<String, dynamic>> day_9 = [
    {
      'question': 'What does a red traffic light mean?',
      'options': ['Stop', 'Go', 'Slow down', 'Yield'],
      'answer': 'Stop'
    },
    {
      'question': 'What should you do when approaching a yellow traffic light?',
      'options': ['Speed up', 'Stop if safe', 'Ignore it', 'Turn immediately'],
      'answer': 'Stop if safe'
    },
    {
      'question': 'What does a green traffic light mean?',
      'options': ['Stop', 'Go if safe', 'Prepare to stop', 'Yield'],
      'answer': 'Go if safe'
    },
    {
      'question': 'What does a flashing red light indicate?',
      'options': ['Proceed with caution', 'Stop completely', 'Speed up', 'Ignore it'],
      'answer': 'Stop completely'
    },
    {
      'question': 'What does a flashing yellow light mean?',
      'options': ['Stop completely', 'Proceed with caution', 'Speed up', 'Turn immediately'],
      'answer': 'Proceed with caution'
    },
    {
      'question': 'What does a pedestrian crossing sign indicate?',
      'options': ['Pedestrians have the right of way', 'No pedestrians allowed', 'Pedestrians must yield to cars', 'Ignore pedestrians'],
      'answer': 'Pedestrians have the right of way'
    },
    {
      'question': 'What does a stop sign require you to do?',
      'options': ['Slow down', 'Come to a full stop', 'Proceed cautiously', 'Ignore it'],
      'answer': 'Come to a full stop'
    },
    {
      'question': 'What does a yield sign mean?',
      'options': ['Stop completely', 'Give way to traffic', 'Speed up', 'Ignore other vehicles'],
      'answer': 'Give way to traffic'
    },
    {
      'question': 'What should you do when you see a school zone sign?',
      'options': ['Speed up', 'Drive carefully and reduce speed', 'Ignore it', 'Honk'],
      'answer': 'Drive carefully and reduce speed'
    },
    {
      'question': 'What does a one-way street sign indicate?',
      'options': ['Traffic moves in one direction', 'You can drive both ways', 'No stopping allowed', 'Pedestrian-only street'],
      'answer': 'Traffic moves in one direction'
    }
  ];

  final List<Map<String, dynamic>> day_10 = [
    {
      'question': 'Why is night driving more dangerous than daytime driving?',
      'options': ['Reduced visibility', 'More traffic', 'Better road conditions', 'More streetlights'],
      'answer': 'Reduced visibility'
    },
    {
      'question': 'What should you do if an oncoming car’s headlights are too bright?',
      'options': ['Look at the road shoulder', 'Flash your headlights', 'Close your eyes briefly', 'Speed up'],
      'answer': 'Look at the road shoulder'
    },
    {
      'question': 'When should you use high beams?',
      'options': ['In heavy traffic', 'On unlit roads', 'When following another car', 'Always'],
      'answer': 'On unlit roads'
    },
    {
      'question': 'When should you use low beams?',
      'options': ['In fog', 'At night in traffic', 'During heavy rain', 'All of the above'],
      'answer': 'All of the above'
    },
    {
      'question': 'What should you do to avoid glare from headlights at night?',
      'options': ['Look straight ahead', 'Look slightly to the right', 'Close one eye', 'Flash your lights'],
      'answer': 'Look slightly to the right'
    },
    {
      'question': 'How should you adjust your speed when driving at night?',
      'options': ['Drive faster', 'Maintain normal speed', 'Drive slower', 'Ignore speed limits'],
      'answer': 'Drive slower'
    },
    {
      'question': 'Why is it harder to judge distances at night?',
      'options': ['Reduced light', 'More distractions', 'Increased traffic', 'Better visibility'],
      'answer': 'Reduced light'
    },
    {
      'question': 'What should you do if your headlights fail at night?',
      'options': ['Turn on hazard lights and stop', 'Keep driving', 'Speed up', 'Use high beams'],
      'answer': 'Turn on hazard lights and stop'
    },
    {
      'question': 'What is the best way to stay alert while driving at night?',
      'options': ['Drink coffee', 'Take regular breaks', 'Drive with the windows down', 'Play loud music'],
      'answer': 'Take regular breaks'
    },
    {
      'question': 'Why should you keep your windshield clean when driving at night?',
      'options': ['To reduce glare', 'To improve air conditioning', 'To prevent accidents', 'For better aerodynamics'],
      'answer': 'To reduce glare'
    }
  ];
  final List<Map<String, dynamic>> day_11 = [
    {
      'question': 'What is the main risk of highway driving?',
      'options': ['Higher speeds', 'More pedestrians', 'Frequent stops', 'Better visibility'],
      'answer': 'Higher speeds'
    },
    {
      'question': 'What should you do before merging onto a highway?',
      'options': ['Stop and wait', 'Speed up to match traffic', 'Use hazard lights', 'Slow down'],
      'answer': 'Speed up to match traffic'
    },
    {
      'question': 'Which lane is generally used for overtaking on highways?',
      'options': ['Left lane', 'Middle lane', 'Right lane', 'Any lane'],
      'answer': 'Right lane'
    },
    {
      'question': 'What is the purpose of highway exit signs?',
      'options': ['To indicate emergency stops', 'To guide drivers to exits', 'To signal a speed limit', 'To show fuel stations'],
      'answer': 'To guide drivers to exits'
    },
    {
      'question': 'Why should you avoid sudden lane changes on highways?',
      'options': ['To improve fuel efficiency', 'To avoid accidents', 'To increase speed', 'To reduce tire wear'],
      'answer': 'To avoid accidents'
    },
    {
      'question': 'How can you maintain a safe following distance on highways?',
      'options': ['By using the two-second rule', 'By tailgating', 'By driving faster', 'By ignoring traffic'],
      'answer': 'By using the two-second rule'
    },
    {
      'question': 'What should you do if you miss an exit on a highway?',
      'options': ['Reverse to the exit', 'Take the next exit', 'Stop immediately', 'Make a U-turn'],
      'answer': 'Take the next exit'
    },
    {
      'question': 'What should you do in case of a breakdown on the highway?',
      'options': ['Stay inside the car', 'Move to the shoulder and call for help', 'Abandon the vehicle', 'Keep driving slowly'],
      'answer': 'Move to the shoulder and call for help'
    },
    {
      'question': 'Why is it important to check mirrors frequently on highways?',
      'options': ['To check your hairstyle', 'To monitor surrounding traffic', 'To improve visibility', 'To reduce speed'],
      'answer': 'To monitor surrounding traffic'
    },
    {
      'question': 'What is the best way to exit a highway safely?',
      'options': ['Brake suddenly', 'Use exit lanes properly', 'Switch lanes at the last minute', 'Slow down immediately'],
      'answer': 'Use exit lanes properly'
    }
  ];

  final List<Map<String, dynamic>> day_12 = [
    {
      'question': 'Why is city driving more challenging than highway driving?',
      'options': ['More traffic signals and pedestrians', 'Faster speeds', 'Fewer turns', 'Better road conditions'],
      'answer': 'More traffic signals and pedestrians'
    },
    {
      'question': 'How should you handle heavy traffic in the city?',
      'options': ['Drive aggressively', 'Be patient and follow traffic rules', 'Use horn frequently', 'Change lanes quickly'],
      'answer': 'Be patient and follow traffic rules'
    },
    {
      'question': 'What should you do when approaching a pedestrian crossing?',
      'options': ['Speed up', 'Stop for pedestrians', 'Honk loudly', 'Ignore the crossing'],
      'answer': 'Stop for pedestrians'
    },
    {
      'question': 'Why is it important to watch for cyclists in the city?',
      'options': ['They can change lanes unexpectedly', 'They are always speeding', 'They have right of way', 'They do not follow traffic rules'],
      'answer': 'They can change lanes unexpectedly'
    },
    {
      'question': 'How can you avoid accidents at city intersections?',
      'options': ['Slow down and check all directions', 'Ignore traffic lights', 'Speed through intersections', 'Follow other drivers closely'],
      'answer': 'Slow down and check all directions'
    },
    {
      'question': 'What should you do when making a left turn in city traffic?',
      'options': ['Use turn signals and check blind spots', 'Speed up', 'Ignore pedestrians', 'Turn without signaling'],
      'answer': 'Use turn signals and check blind spots'
    },
    {
      'question': 'Why should you avoid tailgating in city traffic?',
      'options': ['To maintain fuel efficiency', 'To have enough reaction time', 'To reduce noise pollution', 'To save brake pads'],
      'answer': 'To have enough reaction time'
    },
    {
      'question': 'How should you handle emergency vehicles in city traffic?',
      'options': ['Move to the side and let them pass', 'Speed up', 'Ignore them', 'Block their path'],
      'answer': 'Move to the side and let them pass'
    },
    {
      'question': 'What is the best way to avoid distractions while driving in the city?',
      'options': ['Focus on the road and avoid phone use', 'Listen to loud music', 'Talk to passengers', 'Use mobile phones'],
      'answer': 'Focus on the road and avoid phone use'
    },
    {
      'question': 'Why should you be extra cautious in city traffic at night?',
      'options': ['More pedestrians and reduced visibility', 'Fewer cars on the road', 'Better traffic control', 'Streetlights provide full visibility'],
      'answer': 'More pedestrians and reduced visibility'
    }
  ];
  final List<Map<String, dynamic>> day_13 = [
    {
      'question': 'What is defensive driving?',
      'options': ['Driving aggressively', 'Anticipating potential hazards', 'Ignoring traffic rules', 'Speeding to avoid traffic'],
      'answer': 'Anticipating potential hazards'
    },
    {
      'question': 'How can you reduce the risk of accidents while driving defensively?',
      'options': ['Keep a safe following distance', 'Ignore road signs', 'Drive at maximum speed', 'Honk frequently'],
      'answer': 'Keep a safe following distance'
    },
    {
      'question': 'Why should you check mirrors frequently while driving?',
      'options': ['To admire the scenery', 'To monitor surrounding traffic', 'To check passengers', 'To look at yourself'],
      'answer': 'To monitor surrounding traffic'
    },
    {
      'question': 'What should you do if another driver is tailgating you?',
      'options': ['Brake suddenly', 'Allow them to pass safely', 'Speed up', 'Ignore them'],
      'answer': 'Allow them to pass safely'
    },
    {
      'question': 'Why is it important to scan the road ahead while driving?',
      'options': ['To react early to potential hazards', 'To admire the view', 'To speed up', 'To avoid using brakes'],
      'answer': 'To react early to potential hazards'
    },
    {
      'question': 'What should you do when approaching an intersection?',
      'options': ['Speed up', 'Check for traffic and pedestrians', 'Ignore traffic lights', 'Honk loudly'],
      'answer': 'Check for traffic and pedestrians'
    },
    {
      'question': 'How does maintaining a safe following distance help?',
      'options': ['Gives you more time to react', 'Encourages tailgating', 'Speeds up traffic', 'Reduces fuel consumption'],
      'answer': 'Gives you more time to react'
    },
    {
      'question': 'Why should you avoid distractions while driving?',
      'options': ['It looks unprofessional', 'It reduces reaction time', 'It helps in overtaking', 'It increases speed'],
      'answer': 'It reduces reaction time'
    },
    {
      'question': 'How can you handle road rage from other drivers?',
      'options': ['Ignore aggressive drivers', 'Engage in confrontation', 'Speed away', 'Honk continuously'],
      'answer': 'Ignore aggressive drivers'
    },
    {
      'question': 'What is the best way to handle slippery roads?',
      'options': ['Brake suddenly', 'Drive slowly and avoid sudden movements', 'Speed up to avoid skidding', 'Use high beams'],
      'answer': 'Drive slowly and avoid sudden movements'
    }
  ];

  final List<Map<String, dynamic>> day_14 = [
    {
      'question': 'What should you do in case of a brake failure?',
      'options': ['Pump the brake pedal', 'Turn off the engine', 'Increase speed', 'Jump out of the car'],
      'answer': 'Pump the brake pedal'
    },
    {
      'question': 'What is the safest response to a tire blowout?',
      'options': ['Brake hard', 'Hold the steering wheel firmly and slow down gradually', 'Turn sharply', 'Press the accelerator'],
      'answer': 'Hold the steering wheel firmly and slow down gradually'
    },
    {
      'question': 'How should you react if your car skids?',
      'options': ['Steer in the direction of the skid', 'Brake hard', 'Accelerate', 'Close your eyes and hope for the best'],
      'answer': 'Steer in the direction of the skid'
    },
    {
      'question': 'What should you do if your car engine overheats?',
      'options': ['Continue driving', 'Turn off the engine and let it cool', 'Speed up', 'Pour cold water on the engine'],
      'answer': 'Turn off the engine and let it cool'
    },
    {
      'question': 'How can you prevent accidents in foggy conditions?',
      'options': ['Use fog lights and drive slowly', 'Speed up to get through faster', 'Turn off headlights', 'Ignore road markings'],
      'answer': 'Use fog lights and drive slowly'
    },
    {
      'question': 'What should you do if your accelerator gets stuck?',
      'options': ['Turn off the engine immediately', 'Shift to neutral and apply brakes', 'Press the accelerator harder', 'Jump out of the car'],
      'answer': 'Shift to neutral and apply brakes'
    },
    {
      'question': 'Why should you carry an emergency kit in your car?',
      'options': ['To help in case of breakdowns or accidents', 'To add weight to the car', 'To keep passengers entertained', 'To store snacks'],
      'answer': 'To help in case of breakdowns or accidents'
    },
    {
      'question': 'What is the best way to handle sudden heavy rain while driving?',
      'options': ['Slow down and use wipers', 'Speed up', 'Ignore water puddles', 'Use hazard lights'],
      'answer': 'Slow down and use wipers'
    },
    {
      'question': 'What should you do if your car stalls on a railway crossing?',
      'options': ['Leave the car and move away', 'Try to restart the car immediately', 'Stay inside and wait for help', 'Honk for assistance'],
      'answer': 'Leave the car and move away'
    },
    {
      'question': 'How can you avoid hydroplaning on wet roads?',
      'options': ['Drive slowly and avoid sudden movements', 'Drive fast to clear water quickly', 'Turn sharply', 'Brake hard'],
      'answer': 'Drive slowly and avoid sudden movements'
    }
  ];
  final List<Map<String, dynamic>> day_15 = [
    {
      'question': 'What should you do when driving in heavy rain?',
      'options': ['Use high beams', 'Slow down and use wipers', 'Speed up', 'Ignore water puddles'],
      'answer': 'Slow down and use wipers'
    },
    {
      'question': 'Why is it dangerous to drive in foggy conditions?',
      'options': ['Reduced visibility', 'More traffic', 'Better road conditions', 'Fewer pedestrians'],
      'answer': 'Reduced visibility'
    },
    {
      'question': 'What is the best way to handle snow-covered roads?',
      'options': ['Drive fast to clear the snow', 'Use chains or winter tires and drive slowly', 'Brake hard frequently', 'Ignore road conditions'],
      'answer': 'Use chains or winter tires and drive slowly'
    },
    {
      'question': 'How can you prevent hydroplaning on wet roads?',
      'options': ['Drive slowly and avoid sudden movements', 'Drive fast to clear water quickly', 'Turn sharply', 'Brake hard'],
      'answer': 'Drive slowly and avoid sudden movements'
    },
    {
      'question': 'What should you do when driving in high winds?',
      'options': ['Grip the steering wheel firmly', 'Speed up to avoid wind resistance', 'Ignore the wind', 'Honk frequently'],
      'answer': 'Grip the steering wheel firmly'
    },
    {
      'question': 'How should you handle driving on icy roads?',
      'options': ['Brake suddenly to test traction', 'Drive slowly and avoid sudden movements', 'Speed up to avoid slipping', 'Turn sharply to maintain control'],
      'answer': 'Drive slowly and avoid sudden movements'
    },
    {
      'question': 'What is the safest way to drive through a flooded road?',
      'options': ['Drive fast to avoid water damage', 'Avoid driving through deep water', 'Keep accelerating', 'Turn off headlights'],
      'answer': 'Avoid driving through deep water'
    },
    {
      'question': 'Why should you use fog lights in foggy conditions?',
      'options': ['To increase visibility', 'To signal other drivers', 'To look stylish', 'To improve fuel efficiency'],
      'answer': 'To increase visibility'
    },
    {
      'question': 'What should you do if visibility is extremely low due to fog?',
      'options': ['Stop in a safe place until it clears', 'Drive faster to get through quickly', 'Use high beams', 'Ignore road markings'],
      'answer': 'Stop in a safe place until it clears'
    },
    {
      'question': 'How can you stay safe while driving in extreme heat?',
      'options': ['Keep the AC running at all times', 'Check tire pressure and coolant levels', 'Drive faster', 'Ignore engine temperature'],
      'answer': 'Check tire pressure and coolant levels'
    }
  ];

  final List<Map<String, dynamic>> day_16 = [
    {
      'question': 'How can you improve fuel efficiency while driving?',
      'options': ['Maintain a steady speed', 'Accelerate and brake suddenly', 'Drive at maximum speed', 'Keep the car running when parked'],
      'answer': 'Maintain a steady speed'
    },
    {
      'question': 'Why should you avoid sudden acceleration?',
      'options': ['To reduce fuel consumption', 'To increase tire wear', 'To test the engine power', 'To make driving exciting'],
      'answer': 'To reduce fuel consumption'
    },
    {
      'question': 'What is the best way to reduce fuel consumption on highways?',
      'options': ['Use cruise control', 'Drive at maximum speed', 'Change lanes frequently', 'Avoid using gears'],
      'answer': 'Use cruise control'
    },
    {
      'question': 'How does tire pressure affect fuel efficiency?',
      'options': ['Proper tire pressure improves efficiency', 'Lower pressure saves fuel', 'Higher pressure reduces fuel consumption', 'It has no effect'],
      'answer': 'Proper tire pressure improves efficiency'
    },
    {
      'question': 'Why should you avoid idling for long periods?',
      'options': ['It wastes fuel', 'It improves fuel economy', 'It keeps the engine warm', 'It increases speed'],
      'answer': 'It wastes fuel'
    },
    {
      'question': 'How does carrying extra weight in your car impact fuel efficiency?',
      'options': ['Increases fuel consumption', 'Improves aerodynamics', 'Reduces wear on tires', 'Increases acceleration'],
      'answer': 'Increases fuel consumption'
    },
    {
      'question': 'Why is regular vehicle maintenance important for fuel efficiency?',
      'options': ['To keep the car looking new', 'To ensure optimal engine performance', 'To increase emissions', 'To make repairs expensive'],
      'answer': 'To ensure optimal engine performance'
    },
    {
      'question': 'How can smooth driving improve fuel economy?',
      'options': ['Reduces unnecessary acceleration and braking', 'Increases tire wear', 'Makes the car heavier', 'Has no effect'],
      'answer': 'Reduces unnecessary acceleration and braking'
    },
    {
      'question': 'What is the most fuel-efficient speed range for most cars?',
      'options': ['50-80 km/h', 'Above 120 km/h', 'Below 30 km/h', 'Any speed is fuel-efficient'],
      'answer': '50-80 km/h'
    },
    {
      'question': 'How does using air conditioning affect fuel consumption?',
      'options': ['Increases fuel consumption', 'Has no effect', 'Reduces fuel usage', 'Improves engine power'],
      'answer': 'Increases fuel consumption'
    }
  ];
  final List<Map<String, dynamic>> day_17 = [
    {
      'question': 'Why is road etiquette important?',
      'options': ['To ensure smooth traffic flow', 'To allow speeding', 'To ignore traffic rules', 'To create road rage'],
      'answer': 'To ensure smooth traffic flow'
    },
    {
      'question': 'What should you do when an emergency vehicle approaches?',
      'options': ['Move to the side and let it pass', 'Speed up', 'Ignore it', 'Block its way'],
      'answer': 'Move to the side and let it pass'
    },
    {
      'question': 'How should you behave at pedestrian crossings?',
      'options': ['Stop and allow pedestrians to cross', 'Speed up', 'Honk continuously', 'Ignore pedestrians'],
      'answer': 'Stop and allow pedestrians to cross'
    },
    {
      'question': 'What is the proper way to use your horn?',
      'options': ['To alert others in emergencies', 'To express frustration', 'To demand right of way', 'To scare pedestrians'],
      'answer': 'To alert others in emergencies'
    },
    {
      'question': 'Why should you avoid tailgating?',
      'options': ['To maintain a safe braking distance', 'To increase speed', 'To pressure other drivers', 'To improve fuel efficiency'],
      'answer': 'To maintain a safe braking distance'
    },
    {
      'question': 'What should you do if another driver makes a mistake?',
      'options': ['Stay calm and drive safely', 'Confront them', 'Honk aggressively', 'Block their path'],
      'answer': 'Stay calm and drive safely'
    },
    {
      'question': 'How can you show courtesy to other drivers?',
      'options': ['Allow merging', 'Flash high beams constantly', 'Honk at slow drivers', 'Ignore traffic rules'],
      'answer': 'Allow merging'
    },
    {
      'question': 'What is the best way to handle aggressive drivers?',
      'options': ['Avoid engaging with them', 'Race them', 'Tailgate them', 'Yell at them'],
      'answer': 'Avoid engaging with them'
    },
    {
      'question': 'How can you improve road safety through good etiquette?',
      'options': ['Follow traffic rules', 'Ignore speed limits', 'Overtake aggressively', 'Honk frequently'],
      'answer': 'Follow traffic rules'
    },
    {
      'question': 'Why should you use indicators while changing lanes?',
      'options': ['To communicate your intentions to others', 'To confuse other drivers', 'To slow down traffic', 'To increase road rage'],
      'answer': 'To communicate your intentions to others'
    }
  ];

  final List<Map<String, dynamic>> day_18 = [
    {
      'question': 'What should you do before going on a long-distance trip?',
      'options': ['Check tire pressure and fuel levels', 'Drive continuously without breaks', 'Ignore vehicle maintenance', 'Speed up to reach faster'],
      'answer': 'Check tire pressure and fuel levels'
    },
    {
      'question': 'Why should you take breaks during a long drive?',
      'options': ['To stay alert and avoid fatigue', 'To waste time', 'To increase fuel consumption', 'To speed up travel time'],
      'answer': 'To stay alert and avoid fatigue'
    },
    {
      'question': 'What is the best way to plan a long-distance journey?',
      'options': ['Check the route and weather conditions', 'Drive without a plan', 'Ignore road conditions', 'Avoid checking fuel levels'],
      'answer': 'Check the route and weather conditions'
    },
    {
      'question': 'What should you do if you feel drowsy while driving?',
      'options': ['Take a break and rest', 'Continue driving', 'Speed up', 'Turn on loud music'],
      'answer': 'Take a break and rest'
    },
    {
      'question': 'Why is it important to stay hydrated on a long journey?',
      'options': ['To maintain concentration and energy', 'To increase restroom breaks', 'To slow down driving', 'To stay distracted'],
      'answer': 'To maintain concentration and energy'
    },
    {
      'question': 'What should you do if your car breaks down during a long trip?',
      'options': ['Move to a safe location and call for help', 'Abandon the vehicle', 'Keep driving', 'Ignore warning signs'],
      'answer': 'Move to a safe location and call for help'
    },
    {
      'question': 'How can you avoid distractions while driving long distances?',
      'options': ['Focus on the road and take breaks', 'Use mobile phone', 'Talk to passengers continuously', 'Ignore the road'],
      'answer': 'Focus on the road and take breaks'
    },
    {
      'question': 'What should you check before overtaking on highways?',
      'options': ['Blind spots and oncoming traffic', 'Only the rearview mirror', 'Ignore other vehicles', 'Honk and move'],
      'answer': 'Blind spots and oncoming traffic'
    },
    {
      'question': 'Why should you avoid driving at night on long trips?',
      'options': ['Reduced visibility and increased fatigue', 'Less traffic', 'Better road conditions', 'Higher speed limits'],
      'answer': 'Reduced visibility and increased fatigue'
    },
    {
      'question': 'What is the safest speed to drive on highways for long trips?',
      'options': ['Within the posted speed limits', 'As fast as possible', 'Below 20 km/h', 'Ignore speed signs'],
      'answer': 'Within the posted speed limits'
    }
  ];

  final List<Map<String, dynamic>> day_19 = [
    {
      'question': 'Why is regular vehicle maintenance important?',
      'options': ['To ensure safety and longevity', 'To increase fuel consumption', 'To make driving harder', 'To avoid using brakes'],
      'answer': 'To ensure safety and longevity'
    },
    {
      'question': 'How often should you check engine oil levels?',
      'options': ['Once a month', 'Once a year', 'Before every trip', 'Never'],
      'answer': 'Once a month'
    },
    {
      'question': 'What should you inspect on your tires regularly?',
      'options': ['Tread depth and pressure', 'Color and size', 'Brand name', 'Wheel design'],
      'answer': 'Tread depth and pressure'
    },
    {
      'question': 'What is the purpose of checking brake fluid levels?',
      'options': ['To ensure brakes work properly', 'To improve fuel efficiency', 'To make braking harder', 'To increase speed'],
      'answer': 'To ensure brakes work properly'
    },
    {
      'question': 'Why should you keep your headlights clean?',
      'options': ['To improve visibility at night', 'To increase battery life', 'To reduce energy consumption', 'To avoid scratches'],
      'answer': 'To improve visibility at night'
    },
    {
      'question': 'What should you do if your battery warning light turns on?',
      'options': ['Check the battery and alternator', 'Ignore it', 'Turn off headlights', 'Drive faster'],
      'answer': 'Check the battery and alternator'
    },
    {
      'question': 'Why is it important to replace windshield wipers regularly?',
      'options': ['To maintain clear visibility in rain', 'To improve aerodynamics', 'To make the car look better', 'To avoid washing the windshield'],
      'answer': 'To maintain clear visibility in rain'
    },
    {
      'question': 'What is the purpose of checking coolant levels?',
      'options': ['To prevent engine overheating', 'To clean the fuel tank', 'To reduce oil consumption', 'To make the car faster'],
      'answer': 'To prevent engine overheating'
    },
    {
      'question': 'How can you extend the life of your car’s tires?',
      'options': ['Regular rotation and proper inflation', 'Driving at high speeds', 'Avoiding braking', 'Using them beyond the recommended life'],
      'answer': 'Regular rotation and proper inflation'
    },
    {
      'question': 'Why should you follow the manufacturer’s maintenance schedule?',
      'options': ['To ensure vehicle reliability', 'To increase repair costs', 'To ignore minor repairs', 'To make the car heavier'],
      'answer': 'To ensure vehicle reliability'
    }
  ];

  final List<Map<String, dynamic>> day_20 = [
    {
      'question': 'Why is it important to understand driving laws?',
      'options': ['To avoid fines and penalties', 'To drive faster', 'To ignore speed limits', 'To avoid seatbelts'],
      'answer': 'To avoid fines and penalties'
    },
    {
      'question': 'What documents should you always carry while driving?',
      'options': ['Driving license, registration, and insurance', 'Only the license', 'A road map', 'Service history'],
      'answer': 'Driving license, registration, and insurance'
    },
    {
      'question': 'What happens if you drive without a valid license?',
      'options': ['You may face legal penalties', 'Nothing happens', 'You get extra driving points', 'It improves your driving skills'],
      'answer': 'You may face legal penalties'
    },
    {
      'question': 'Why should you obey speed limits?',
      'options': ['To ensure road safety', 'To test your car’s speed', 'To avoid fuel efficiency', 'To race other drivers'],
      'answer': 'To ensure road safety'
    },
    {
      'question': 'What should you do if you receive a traffic ticket?',
      'options': ['Pay the fine or contest it legally', 'Ignore it', 'Speed away', 'Destroy the ticket'],
      'answer': 'Pay the fine or contest it legally'
    },
    {
      'question': 'Why is it illegal to drink and drive?',
      'options': ['It impairs judgment and reaction time', 'It saves fuel', 'It improves driving skills', 'It is recommended for long trips'],
      'answer': 'It impairs judgment and reaction time'
    },
    {
      'question': 'What does a seatbelt law require?',
      'options': ['All occupants must wear seatbelts', 'Only drivers need to wear seatbelts', 'Only children need seatbelts', 'Seatbelts are optional'],
      'answer': 'All occupants must wear seatbelts'
    },
    {
      'question': 'What should you do if you are involved in an accident?',
      'options': ['Report it to authorities and exchange information', 'Drive away quickly', 'Ignore it', 'Blame the other driver'],
      'answer': 'Report it to authorities and exchange information'
    },
    {
      'question': 'What is the purpose of vehicle insurance?',
      'options': ['To provide financial protection in case of accidents', 'To increase fuel efficiency', 'To reduce repair costs', 'To make cars expensive'],
      'answer': 'To provide financial protection in case of accidents'
    },
    {
      'question': 'Why is it important to follow lane discipline?',
      'options': ['To avoid accidents and confusion', 'To slow down traffic', 'To increase congestion', 'To overtake anytime'],
      'answer': 'To avoid accidents and confusion'
    }
  ];
  final List<Map<String, dynamic>> day_21 = [
    {
      'question': 'Why is a final driving review important?',
      'options': ['To refresh all learned skills', 'To ignore previous lessons', 'To prepare for a racing event', 'To test vehicle speed'],
      'answer': 'To refresh all learned skills'
    },
    {
      'question': 'What should you focus on during your final practice?',
      'options': ['Areas of difficulty', 'Only speed control', 'Ignoring road signs', 'Avoiding turns'],
      'answer': 'Areas of difficulty'
    },
    {
      'question': 'Why is confidence important in driving?',
      'options': ['To make decisions quickly', 'To drive aggressively', 'To ignore other vehicles', 'To avoid braking'],
      'answer': 'To make decisions quickly'
    },
    {
      'question': 'What is the best way to test your driving skills?',
      'options': ['Taking a mock driving test', 'Speeding on highways', 'Ignoring traffic rules', 'Driving without supervision'],
      'answer': 'Taking a mock driving test'
    },
    {
      'question': 'How can you improve weak driving skills?',
      'options': ['Practice in a safe environment', 'Avoid practicing', 'Only watch videos', 'Ignore feedback'],
      'answer': 'Practice in a safe environment'
    },
    {
      'question': 'What should you do if you fail a driving test?',
      'options': ['Analyze mistakes and practice more', 'Stop driving completely', 'Blame the instructor', 'Ignore feedback'],
      'answer': 'Analyze mistakes and practice more'
    },
    {
      'question': 'Why is ongoing practice important after training?',
      'options': ['To maintain and improve skills', 'To forget learned techniques', 'To avoid road rules', 'To test car limits'],
      'answer': 'To maintain and improve skills'
    },
    {
      'question': 'What should you always remember before driving alone?',
      'options': ['Follow all safety measures', 'Ignore seatbelts', 'Drive as fast as possible', 'Avoid road signs'],
      'answer': 'Follow all safety measures'
    },
    {
      'question': 'How can you stay a responsible driver?',
      'options': ['By following traffic rules and driving safely', 'By ignoring signals', 'By driving recklessly', 'By avoiding mirrors'],
      'answer': 'By following traffic rules and driving safely'
    },
    {
      'question': 'What is the key takeaway from a 21-day driving school?',
      'options': ['Safe and confident driving', 'Racing skills', 'Ignoring road rules', 'Driving without learning'],
      'answer': 'Safe and confident driving'
    }
  ];
  late final Map<int, List<Map<String, dynamic>>> quizData;
  late List<Map<String, dynamic>> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    quizData = {
      1: day_1,
      2: day_2,
      3: day_3,
      4: day_4,
      5: day_5,
      6: day_6,
      7: day_7,
      8: day_8,
      9: day_9,
      10: day_10,
      11: day_11,
      12: day_12,
      13: day_13,
      14: day_14,
      15: day_15,
      16: day_16,
      17: day_17,
      18: day_18,
      19: day_19,
      20: day_20,
      21: day_21,
    };
    _questions = quizData[widget.dayIndex] ?? [];
  }
  void _answerQuestion(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });

    bool isCorrect = answer == _questions[_currentQuestionIndex]['answer'];
    if (isCorrect) _score++;

    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _selectedAnswer = null;
        _currentQuestionIndex++;
        if (_currentQuestionIndex >= _questions.length) {
          _quizCompleted = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz: Day ${widget.dayIndex}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
          ),
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _quizCompleted ? 'Completed' : '${_currentQuestionIndex + 1}/${_questions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6],
          ),
        ),
        child: _quizCompleted
            ? _buildQuizCompletedScreen()
            : _buildQuestionScreen(),
      ),
    );
  }

  Widget _buildQuizCompletedScreen() {
    // Calculate the percentage score
    final percentage = (_score / _questions.length) * 100;
    final bool passed = _score > _questions.length / 2;

    return Center(
      child: FadeInUp(
        duration: Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shadowColor: Colors.blueAccent.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Result badge
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: passed ? Colors.green.shade50 : Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: passed ? Colors.green : Colors.red,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            passed ? Icons.check_circle : Icons.sentiment_dissatisfied,
                            size: 50,
                            color: passed ? Colors.green : Colors.red,
                          ),
                          SizedBox(height: 4),
                          Text(
                            passed ? 'PASSED' : 'TRY AGAIN',
                            style: TextStyle(
                              color: passed ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Quiz Completed!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Animated score counter
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: percentage),
                    duration: Duration(seconds: 1),
                    builder: (context, double value, child) {
                      return Column(
                        children: [
                          Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: passed ? Colors.green : Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your Score: $_score/${_questions.length}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  // Feedback message
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: passed ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: passed ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Text(
                      passed
                          ? 'Congratulations! You have successfully completed the quiz.'
                          : 'You need to score at least 50% to pass. Try again!',
                      style: TextStyle(
                        fontSize: 16,
                        color: passed ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Continue button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed ? Colors.green : Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: (passed ? Colors.green : Colors.blueAccent).withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pop(context, passed);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(passed ? Icons.check : Icons.refresh),
                        SizedBox(width: 8),
                        Text(
                          passed ? 'Continue' : 'Try Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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

  Widget _buildQuestionScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Card(
                    elevation: 8,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent.shade100, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: FadeIn(
                        duration: Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 40,
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              _questions[_currentQuestionIndex]['question'] as String,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Options
                  ...(_questions[_currentQuestionIndex]['options'] as List<String>)
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    List<String> optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];
                    String optionLabel = index < optionLabels.length ? optionLabels[index] : (index + 1).toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ZoomIn(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        child: Card(
                          elevation: 3,
                          shadowColor: Colors.blueAccent.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _answerQuestion(option),
                            splashColor: Colors.blueAccent.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Option label circle
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        optionLabel,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}