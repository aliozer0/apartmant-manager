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
  }
}
