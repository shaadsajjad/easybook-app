import 'package:easybook_app/bootstrap.dart';
import 'package:easybook_app/core/config/app_config.dart';
import 'package:easybook_app/core/config/flavor.dart';

Future<void> main() async {
  await bootstrap(AppConfig.forFlavor(Flavor.staging));
}
