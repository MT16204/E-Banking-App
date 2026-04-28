import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:banking_app/data/repositories/auth_repository.dart';
import 'package:banking_app/data/repositories/current_user_repository.dart';
import 'package:banking_app/data/repositories/wallet_repository.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final CurrentUserRepository currentUserRepository;
  final WalletRepository walletRepository;

  ProfileBloc({
    required this.authRepository,
    required this.currentUserRepository,
    required this.walletRepository,
  }) : super(const ProfileInitial()) {
    on<ProfileStarted>(_load);
    on<ProfileRefreshed>(_load);
    on<ProfileLogoutRequested>(_logout);
  }

  Future<void> _load(
    ProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const ProfileLoading());
    }
    try {
      final user = await currentUserRepository.getCurrentUser();
      final wallet = await walletRepository.getWalletByUserId(user.$id);
      emit(ProfileLoaded(user: user, wallet: wallet));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _logout(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(isLoggingOut: true));
    } else {
      emit(const ProfileLoading());
    }
    try {
      await authRepository.signOut();
      emit(const ProfileLoggedOut());
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
