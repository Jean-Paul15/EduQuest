import 'dart:io';
import 'package:eduquest/features/app_config/domain/update_policy.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateGateResult {
  const UpdateGateResult({required this.required, required this.message, required this.storeUrl});
  final bool required;
  final String message;
  final String storeUrl;
}

class UpdateGateService {
  Future<UpdateGateResult> evaluate(UpdatePolicy p) async {
    if (!p.enabled) return const UpdateGateResult(required: false, message: '', storeUrl: '');
    final info = await PackageInfo.fromPlatform();
    final localBuild = int.tryParse(info.buildNumber) ?? 0;
    final minBuild = p.platform['min_build_number'] as int? ?? 0;
    final latestBuild = p.platform['latest_build_number'] as int? ?? minBuild;
    final force = p.platform['force_update'] as bool? ?? false;
    final mustUpdate = p.enforceExactMatch ? localBuild != latestBuild : localBuild < minBuild;
    final required = force && mustUpdate;
    final url = p.platform['store_url']?.toString() ?? '';
    return UpdateGateResult(required: required, message: p.message, storeUrl: url);
  }

  String platformKey() => Platform.isIOS ? 'ios' : 'android';
}

