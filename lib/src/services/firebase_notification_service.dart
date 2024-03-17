import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:on_demand_grocery_store/src/repositories/store_repository.dart';

class HNotificationService {
  static final FirebaseMessaging _fbMessaging = FirebaseMessaging.instance;

  static Future initializeFirebaseCloudMessaging() async {
    await _fbMessaging.requestPermission();
    getToken();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    _fbMessaging.subscribeToTopic('Store');
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {}
  static Future<void> _firebaseMessagingForegroundHandler(
      RemoteMessage message) async {}

  static Future getToken() async {
    String? token = await _fbMessaging.getToken();
    await StoreRepository.instance
        .updateSingleField({'CloudMessagingToken': token});
  }

  static sendNotificationToDeliveryPerson() {}
}
