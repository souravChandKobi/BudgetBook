import 'dart:developer' show log;

import 'package:budget_book_app/blocs/auth/auth_event.dart';
import 'package:budget_book_app/blocs/auth/auth_repository/auth_repository.dart';
import 'package:budget_book_app/blocs/budgets/repository/budget_repository.dart';
import 'package:budget_book_app/blocs/sync/sync_repository/sync_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvent, void> {
  final AuthRepository authRepository;
  final SyncRepository syncRepository;

  AuthBloc({required this.authRepository, required this.syncRepository}) : super(null){
    on<SignInToGoogleRequested>((event, emit) async {
      final userCred = await authRepository.signInWithGoogle();
      if (userCred == null) return;

      // await syncRepository.currentUserData();
      // await syncRepository.initialSync();
      // await syncRepository.syncLocalItemsToCloud();

      // await syncRepository.startSync();

      try {
  await syncRepository.initializeCloudSync();
} catch (e, stackTrace) {
  log(
    "Failed to initialize cloud sync",
    error: e,
    stackTrace: stackTrace,
  );
}
    });

    on<SignOutRequested>((event, emit) async {
      await syncRepository.stopSync();
  await authRepository.signOut();

      log("from budget_bloc.dart: 👋 User signed out safely");
    });
  }
}
