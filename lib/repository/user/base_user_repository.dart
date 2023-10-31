import '../../model/user_model.dart';

abstract class BaseUserRepository {
  Stream<User> getUser(String userId);
  
}