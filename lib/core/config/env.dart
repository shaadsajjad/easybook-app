/// Per-environment constants.
///
/// This is the ONLY place in the codebase where the API base URL is written.
abstract final class Env {
  // Production API (Render). Includes the /api/v1 prefix.
  static const String productionBaseUrl =
      'https://easybook-api-d89z.onrender.com/api/v1';

  // For now all flavors use the production API.
  // To use a local backend later, change only these values:
  //   Android emulator: http://10.0.2.2:4000/api/v1
  //   iOS simulator:    http://localhost:4000/api/v1
  static const String developmentBaseUrl = productionBaseUrl;
  static const String stagingBaseUrl = productionBaseUrl;
}
