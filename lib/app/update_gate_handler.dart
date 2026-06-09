import 'package:eduquest/features/app_config/data/app_config_repository.dart';
import 'package:eduquest/features/app_config/data/update_gate_service.dart';
import 'package:eduquest/shared/network/network_probe.dart';

Future<UpdateGateResult> evaluateUpdateGate({
  required AppConfigRepository config,
  required UpdateGateService gate,
}) async {
  try {
    final policy = await config.loadUpdatePolicy(gate.platformKey());
    var result = await gate.evaluate(policy);
    if (result.required) {
      final online = await NetworkProbe.hasConnection();
      if (!online) {
        result = const UpdateGateResult(required: false, message: '', storeUrl: '');
      }
    }
    return result;
  } catch (_) {
    return const UpdateGateResult(required: false, message: '', storeUrl: '');
  }
}
