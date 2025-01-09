
import '../global/index.dart';
import '../index.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<APIService>(() => APIService());
}
