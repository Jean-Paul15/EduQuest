import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/core/result.dart';

abstract class AccessRepositoryInterface {
  const AccessRepositoryInterface();

  Future<Result<AccessState>> resolveAccess();
  Future<Result<bool>> hasAccess(String contentType);
}
