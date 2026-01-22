import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/services/fcm_service.dart';

final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService.instance;
});

final fcmTokenProvider = StateProvider<String?>((ref) {
  return FCMService.instance.fcmToken;
});

final notificationTopicsProvider = NotifierProvider<NotificationTopicsNotifier, Set<String>>(NotificationTopicsNotifier.new);

class NotificationTopicsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  Future<void> subscribe(String topic) async {
    await FCMService.instance.subscribeToTopic(topic);
    state = {...state, topic};
  }

  Future<void> unsubscribe(String topic) async {
    await FCMService.instance.unsubscribeFromTopic(topic);
    state = {...state}..remove(topic);
  }

  void clear() {
    for (final topic in state) {
      FCMService.instance.unsubscribeFromTopic(topic);
    }
    state = {};
  }
}