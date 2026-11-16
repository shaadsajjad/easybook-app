import 'package:easybook_app/core/config/env.dart';
import 'package:easybook_app/core/config/flavor.dart';
import 'package:equatable/equatable.dart';

/// Immutable settings for the running flavor. Registered in get_it so the
/// Dio client can read the base URL; nothing else ever sees a URL.
class AppConfig extends Equatable {
  const new({required this.flavor, required this.baseUrl});

  factory forFlavor(Flavor flavor) {
    return AppConfig(
      flavor: flavor,
      baseUrl: switch (flavor) {
        Flavor.development => Env.developmentBaseUrl,
        Flavor.staging => Env.stagingBaseUrl,
        Flavor.production => Env.productionBaseUrl,
      },
    );
  }

  final Flavor flavor;
  final String baseUrl;

  /// Debug logging is allowed only in the development flavor.
  bool get enableLogging => flavor == Flavor.development;

  @override
  List<Object> get props => [flavor, baseUrl];
}
