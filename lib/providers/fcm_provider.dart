import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/services/fcm_service.dart';

/// Provider cung cấp dịch vụ FCM
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService.instance;
});

/// Provider lưu trữ FCM token
final fcmTokenProvider = StateProvider<String?>((ref) {
  return FCMService.instance.fcmToken;
});

/// Provider quản lý các topic đã đăng ký nhận thông báo
final notificationTopicsProvider =
    NotifierProvider<NotificationTopicsNotifier, Set<String>>(
      NotificationTopicsNotifier.new,
    );

/// Quản lý trạng thái các topic thông báo
class NotificationTopicsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Đăng ký nhận thông báo từ topic
  Future<void> subscribe(String topic) async {
    await FCMService.instance.subscribeToTopic(topic);
    state = {...state, topic};
  }

  /// Hủy đăng ký nhận thông báo từ topic
  Future<void> unsubscribe(String topic) async {
    await FCMService.instance.unsubscribeFromTopic(topic);
    state = {...state}..remove(topic);
  }

  /// Xóa tất cả các topic đã đăng ký
  void clear() {
    for (final topic in state) {
      FCMService.instance.unsubscribeFromTopic(topic);
    }
    state = {};
  }
}
