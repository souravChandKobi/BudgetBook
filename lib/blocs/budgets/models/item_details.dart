import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';

class ItemDetailsView {
  final String monthLabel;
  final int total;
  final int totalQty;
  final List<BudgetItem> items;

  ItemDetailsView({
    required this.monthLabel,
    required this.total,
    required this.totalQty,
    required this.items,
  });
}
