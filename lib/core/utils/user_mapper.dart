import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';

/// Shared mapper for Firebase [User] → serialized user [Map].
///
/// Eliminates duplication between [AuthRemoteDataSource] and
/// [AuthRepositoryImpl] — single source of truth for user serialization.
abstract final class UserMapper {
  /// Serializes a Firebase [User] into the standard user map.
  ///
  /// Keys: `uid`, `email`, `name`, `photoUrl`, `role`.
  static Map<String, dynamic> toMap(User user) {
    return <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'name': (user.displayName == null || user.displayName!.isEmpty)
          ? (user.email ?? 'Admin')
          : user.displayName!,
      'photoUrl': user.photoURL,
      'role': AppConstants.roleAdmin,
    };
  }
}
