import 'dart:async';
import 'dart:developer' show Service, log;

import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetRepository {
  final Box<BudgetItem> box;
  final Box settingsBox;

  BudgetRepository(this.box, this.settingsBox);

  //Read the Items from box and return it
  List<BudgetItem> getAllItems() {
    return box.values.toList();
  }

  //Add items
  Future<void> addItems(BudgetItem item) async {
    await box.put(item.id, item);
    log('from budget_repository.dart: Saved item to HIVE: ${item.id}');

  }

  //update item
  Future<void> updateItem(BudgetItem updatedItem) async {
    await box.put(updatedItem.id, updatedItem);
  }

  //delete item
  Future<void> deleteItem(String id) async {
    await box.delete(id);
  }

  Future<void> setBudget(int monthBudget, int weekBudget, int dayBudget) async {
    await settingsBox.put('monthlyBudget', monthBudget);
    await settingsBox.put('weeklyBudget', weekBudget);
    await settingsBox.put('dailyBudget', dayBudget);
  }

  int get monthlyBudget =>
      settingsBox.get('monthlyBudget', defaultValue: 0) as int;

  int get weeklyBudget =>
      settingsBox.get('weeklyBudget', defaultValue: 0) as int;

  int get dailyBudget => settingsBox.get('dailyBudget', defaultValue: 0) as int;

 
}
