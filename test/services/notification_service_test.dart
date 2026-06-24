import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    test('service class exists', () {
      expect(NotificationService, isNotNull);
    });
  });
}
