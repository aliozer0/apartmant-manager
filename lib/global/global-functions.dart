import 'package:apartmantmanager/modules/news/news-service.dart';

import '../index.dart';
import 'index.dart';

class GlobalFunction {
  Future getItInital() async {
    if (!GetIt.I.isRegistered<GlobalService>()) {
      GetIt.I.registerSingleton<GlobalService>(GlobalService());
    }
    if (!GetIt.I.isRegistered<ExpensesService>()) {
      GetIt.I.registerSingleton<ExpensesService>(ExpensesService());
    }
    if (!GetIt.I.isRegistered<NewsService>()) {
      GetIt.I.registerSingleton<NewsService>(NewsService());
    }
  }
}
