import 'package:apartmantmanager/Global/index.dart';
import 'package:apartmantmanager/index.dart';
import 'package:apartmantmanager/modules/expenses/expenses-model.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  final String apartmentUid;

  const Expenses({
    super.key,
    required this.apartmentUid,
  });

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses>
    with SingleTickerProviderStateMixin {
  final _service = GetIt.I<ExpensesService>();
  late final TabController _tabController;
  final _totalAmount$ = BehaviorSubject<double>.seeded(0);
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _totalAmount$.close();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);
      await _service.incomeAndExpenses(widget.apartmentUid);
      _calculateTotalAmount();
    } catch (e) {
      setState(() => _error = e.toString());
      debugPrint('Error fetching expenses: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onTabChanged() {
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    if (_service.incomeAndExpensesList$.value == null) return;

    List<IncomeAndExpensesModel> filteredList = [];
    switch (_tabController.index) {
      case 0:
        filteredList = _service.incomeAndExpensesList$.value!;
      case 1:
        filteredList = _service.incomeAndExpensesList$.value!
            .where((item) => item.typeid == 1)
            .toList();
      case 2:
        filteredList = _service.incomeAndExpensesList$.value!
            .where((item) => item.typeid == -1)
            .toList();
    }

    final totalAmount = filteredList.fold(
      0.0,
      (prev, item) => prev + (item.amount ?? 0),
    );

    _totalAmount$.add(totalAmount.abs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Income & Expenses'.tr(),
        style: AppTextStyles.cardTitle.copyWith(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelStyle: AppTextStyles.cardTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.cardTitle.copyWith(
          color: Colors.white.withOpacity(0.8),
        ),
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          color: Colors.white,
        ),
        tabs: [
          Tab(text: 'All'.tr()),
          Tab(text: 'Income'.tr()),
          Tab(text: 'Expenses'.tr()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: GlobalConfig.primaryColor,
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    return StreamBuilder<List<IncomeAndExpensesModel>?>(
      stream: _service.incomeAndExpensesList$.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyView();
        }

        return Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesList(snapshot.data!, "All"),
                  _buildExpensesList(
                    snapshot.data!.where((item) => item.typeid == 1).toList(),
                    "Income",
                  ),
                  _buildExpensesList(
                    snapshot.data!.where((item) => item.typeid == -1).toList(),
                    "Expenses",
                  ),
                ],
              ),
            ),
            _buildTotalAmount(),
          ],
        );
      },
    );
  }

  Widget _buildErrorView() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading data'.tr(),
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh'.tr(),
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions found'.tr(),
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh'.tr(),
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(
      List<IncomeAndExpensesModel> items, String tabName) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available for $tabName'.tr(),
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeData,
      color: GlobalConfig.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildExpenseCard(items[index]),
      ),
    );
  }

  Widget _buildExpenseCard(IncomeAndExpensesModel item) {
    final bool isIncome = item.typeid == 1;
    final incomeColor = isIncome ? Colors.green : Colors.red;

    //details page ile aynı tasarım olacak
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        title: Text(
          item.description ?? '',
          style: AppTextStyles.cardTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            DateFormat('dd.MM.yyyy').format(item.date ?? DateTime.now()),
            style: AppTextStyles.bodyText.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "₺${item.amount?.toStringAsFixed(2)}",
            style: AppTextStyles.cardTitle.copyWith(
              color: incomeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Card tempExpenseCard(
      IncomeAndExpensesModel item, MaterialColor color, bool isIncome) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.description ?? '',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${isIncome ? '+' : '-'}₺${item.amount?.toStringAsFixed(2)}",
                    style: AppTextStyles.cardTitle.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd.MM.yyyy').format(item.date ?? DateTime.now()),
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return StreamBuilder<double>(
      stream: _totalAmount$.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return const SizedBox.shrink();
        }

        final amount = snapshot.data!;
        final isNegative = _tabController.index == 2;
        final displayAmount =
            "${isNegative ? '-' : ''}₺${amount.toStringAsFixed(2)}";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: GlobalConfig.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Text(
                  'Total Amount'.tr(),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  displayAmount,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
