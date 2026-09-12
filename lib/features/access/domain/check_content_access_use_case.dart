import 'package:eduquest/features/access/data/access_repository.dart';
import 'package:eduquest/shared/core/result.dart';

/// Business rules for content access checks:
/// - FREE users can access free content only.
/// - FULL/HALF require a valid (non-expired) subscription.
/// - Expired tickets grant no access.
class CheckContentAccessUseCase {
  const CheckContentAccessUseCase();

  Result<bool> call(AccessState state, String contentType) {
    return success<bool>(state.canConsume(contentType));
  }
}
