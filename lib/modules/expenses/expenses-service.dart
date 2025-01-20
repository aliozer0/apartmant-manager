import 'package:apartmantmanager/modules/expenses/expenses-model.dart';
import 'package:http/http.dart' as http;

import '../../global/index.dart';

class ExpensesService {
  BehaviorSubject<List<IncomeAndExpensesModel>?> incomeAndExpensesList$ = BehaviorSubject.seeded(null);

  Future<RequestResponse?> incomeAndExpenses() async {
    try {
      var response = await http.post(Uri.parse(GlobalConfig.url),
          body: json.encode({
            "Action": "Execute",
            "Object": "SP_MOBILE_APARTMENT_MONTHLY_EXPENSE",
            "Parameters": {"APARTMENTUID": apartmentUid}
          }));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        List<IncomeAndExpensesModel> incomeAndExpenses = [];

        data[0].forEach((item) {
          IncomeAndExpensesModel incomeAndExpensesModel = IncomeAndExpensesModel.fromJson(item);
          incomeAndExpenses.add(incomeAndExpensesModel);
        });
        incomeAndExpensesList$.add(incomeAndExpenses);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
