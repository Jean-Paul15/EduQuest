import 'package:eduquest/features/gamification/domain/gamification_repository_interface.dart';
import 'package:eduquest/shared/core/result.dart';

/// Business rule: a user can claim the daily check-in only once per day.
/// Wraps [GamificationRepositoryInterface.claimDailyCheckin] with validation.
class ClaimCheckinUseCase {
  const ClaimCheckinUseCase({required this.repository});

  final GamificationRepositoryInterface repository;

  Future<Result<String>> call() async {
    final result = await repository.claimDailyCheckin();
    if (result.isFailure) return result;
    final message = result.dataOrNull ?? '';
    if (message.contains('déjà') || message.contains('already')) {
      return failure<String>(
        const AuthError(message: 'Check-in déjà effectué aujourd\'hui.'),
      );
    }
    return success<String>(message);
  }
}
