import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static const taskName = 'crashDetectionTask';
  
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
    );
  }

  static Future<void> startMonitoring() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> stopMonitoring() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This will be called in the background
    return true;
  });
}   