import 'package:eduquest/features/engagement/domain/engagement_detail.dart';
import 'package:eduquest/features/engagement/domain/engagement_item.dart';
import 'package:eduquest/shared/core/result.dart';

abstract class EngagementRepositoryInterface {
  const EngagementRepositoryInterface();

  Future<Result<List<EngagementItem>>> listFeed();
  Future<Result<EngagementDetail>> getDetail(String id);
  Future<Result<String>> joinContest(String contestId);
  Future<Result<String>> joinEvent(String eventId);
}
