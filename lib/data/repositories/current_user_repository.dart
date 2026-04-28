import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class CurrentUserRepository {
  final Account account;

  CurrentUserRepository(this.account);

  Future<models.User> getCurrentUser() => account.get();
}
