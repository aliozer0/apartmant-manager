import 'package:apartmantmanager/Global/index.dart';
import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/modules/expenses/expenses-model.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({
    super.key,
  });

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> with SingleTickerProviderStateMixin {
  final service = GetIt.I<ExpensesService>();
  late TabController tabController;
  BehaviorSubject<double> totalAmount$ = BehaviorSubject.seeded(0);

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    service.incomeAndExpenses();
    super.initState();
  }

  void _onTabChanged() {
    double totalAmount = 0;
    List<IncomeAndExpensesModel> filteredList = [];

    switch (tabController.index) {
      case 0:
        filteredList = service.incomeAndExpensesList$.value!;
        break;
      case 1: // Income Tab
        filteredList = service.incomeAndExpensesList$.value!.where((item) => item.typeid == 1).toList();
        break;
      case 2: // Expenses Tab
        filteredList = service.incomeAndExpensesList$.value!.where((item) => item.typeid == -1).toList();
        break;
    }

    totalAmount = filteredList.fold(0, (previousValue, element) => previousValue + (element.amount ?? 0));

    if (totalAmount < 0) {
      totalAmount$.add(-totalAmount);
    } else {
      totalAmount$.add(totalAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    double W = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: service.incomeAndExpensesList$.stream,
        builder: (context, snapshot) {
          if (service.incomeAndExpensesList$.value == null) return const Center(child: CircularProgressIndicator());

          if (totalAmount$.value == 0) {
            double totalAmount = service.incomeAndExpensesList$.value!.fold(0, (previousValue, element) => previousValue + (element.amount ?? 0));
            totalAmount$.add(totalAmount);
          }
          return DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: Scaffold(
                  appBar: AppBar(
                      title: Text('Income & Expenses'.tr()),
                      bottom: TabBar(
                          isScrollable: false,
                          labelStyle: k25Gilroy(context),
                          unselectedLabelStyle: k25Gilroy(context).copyWith(color: Colors.white),
                          indicator: const BoxDecoration(
                              borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)), color: Colors.white),
                          controller: tabController,
                          tabs: [Tab(text: 'All'.tr()), Tab(text: 'Income'.tr()), Tab(text: 'Expenses'.tr())]),
                      leading: InkWell(child: const Icon(Icons.arrow_back_ios, color: Colors.white), onTap: () => Navigator.pop(context))),
                  body: Column(children: [
                    Expanded(
                        child: TabBarView(controller: tabController, children: [
                      incomeItem(service.incomeAndExpensesList$.value ?? [], "All", context),
                      incomeItem(service.incomeAndExpensesList$.value?.where((item) => item.typeid == 1).toList() ?? [], "Income", context),
                      incomeItem(service.incomeAndExpensesList$.value?.where((item) => item.typeid == -1).toList() ?? [], "Expenses", context)
                    ])),
                    StreamBuilder(
                        stream: totalAmount$,
                        builder: (context, snapshot) {
                          String displayAmount = "${totalAmount$.value ?? 0} TL";
                          if (totalAmount$.value < 0) {
                            displayAmount = "-${totalAmount$.value.abs()} TL";
                          }
                          if (totalAmount$.value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                              margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 10, left: 10, right: 10),
                              padding: paddingAll10,
                              decoration: BoxDecoration(color: GlobalConfig.primaryColor, borderRadius: borderRadius10),
                              width: W,
                              child: Row(children: [
                                Expanded(child: Text('Total Amount'.tr(), style: k25Gilroy(context).copyWith(color: Colors.white, fontSize: 20))),
                                Text(displayAmount, style: k25Gilroy(context).copyWith(color: Colors.white, fontSize: 20))
                              ]));
                        })
                  ])));
        });
  }
}

Widget incomeItem(List<IncomeAndExpensesModel> items, String tabName, BuildContext context) {
  double W = MediaQuery.of(context).size.width;
  if (items.isEmpty) {
    return Center(child: Text('No data available for $tabName'.tr(), style: k22Gilroy(context).copyWith(fontSize: 18, color: Colors.grey)));
  }
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return Container(
          padding: paddingAll10,
          margin: marginAll5,
          decoration: BoxDecoration(
              borderRadius: borderRadius10,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
            if (item.description != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.description != null) Expanded(child: Text(item.description ?? '', style: k22Gilroy(context))),
                  if (item.amount != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "${item.typeid == -1 ? '-' : ''} ${item.amount} TL",
                          style: k22Gilroy(context).copyWith(color: item.typeid == 1 ? Colors.green : Colors.red),
                        )),
                ],
              ),
            SizedBox(height: W / 40),
            if (item.date != null) Text(DateFormat('dd.MM.yyyy').format(item.date!), style: k22Gilroy(context))
          ]));
    },
  );
}
