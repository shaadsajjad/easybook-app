import 'package:easybook_app/app/app.dart';
import 'package:easybook_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
