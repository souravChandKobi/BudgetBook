import 'dart:developer' show log;

import 'package:budget_book_app/blocs/auth/auth_event.dart';
import 'package:budget_book_app/blocs/auth/auth_repository/auth_repository.dart';
import 'package:budget_book_app/blocs/budgets/repository/budget_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvent, void> {
  final AuthRepository authRepository;
  final BudgetRepository budgetRepository;

  AuthBloc({required this.authRepository, required this.budgetRepository}) : super(null){
    on<SignInToGoogleRequested>((event, emit) async {
      final userCred = await authRepository.signInWithGoogle();
      if (userCred == null) return;

      await budgetRepository.currentUserData();
      await budgetRepository.initialSync();
      await budgetRepository.syncLocalItemsToCloud();

      await budgetRepository.startSync();
    });

    on<SignOutRequested>((event, emit) async {
      await budgetRepository.stopSync();
  await authRepository.signOut();

      log("from budget_bloc.dart: 👋 User signed out safely");
    });
  }
}
