abstract class BudgetEvent {}

class LoadBudget extends BudgetEvent {}

class AddBudgetItem extends BudgetEvent {
  final dynamic item;
  AddBudgetItem(this.item);
}

class UpdateBudgetItem extends BudgetEvent {
  final dynamic updatedItem;
  UpdateBudgetItem(this.updatedItem);
}

class DeleteBudgetItem extends BudgetEvent {
  final String itemId;
  DeleteBudgetItem(this.itemId);
}

class SetBudgets extends BudgetEvent {
  final int monthBudget;
  final int weekBudget;
  final int dayBudget;
  SetBudgets(this.monthBudget, this.weekBudget, this.dayBudget);
}

class RefreshBudget extends BudgetEvent {}

class SignInToGoogleRequested extends BudgetEvent {}

class CloudSyncRequested extends BudgetEvent {}

class SignOutRequested extends BudgetEvent {}

class LocalItemsChanged extends BudgetEvent {}

//For the itemDataScreen
class LoadItemData extends BudgetEvent {
  final String itemName;
  LoadItemData(this.itemName);
}

class RenameBudgetItems extends BudgetEvent {
  final String oldName;
  final String newName;
  final String category;

  RenameBudgetItems({
    required this.category,
    required this.newName,
    required this.oldName,
  });
}
