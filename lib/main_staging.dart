import 'package:notif_analytics/config/app_flavor.dart';
import 'package:notif_analytics/main.dart' as app;

Future<void> main() async {
  await app.bootstrap(flavor: AppFlavor.staging);
}
