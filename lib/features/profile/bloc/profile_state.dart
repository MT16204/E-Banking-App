import 'package:appwrite/models.dart' as models;
import 'package:banking_app/data/models/models.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final models.User user;
  final WalletModel? wallet;
  final bool isRefreshing;
  final bool isLoggingOut;

  const ProfileLoaded({
    required this.user,
    required this.wallet,
    this.isRefreshing = false,
    this.isLoggingOut = false,
  });

  ProfileLoaded copyWith({
    models.User? user,
    WalletModel? wallet,
    bool? isRefreshing,
    bool? isLoggingOut,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
