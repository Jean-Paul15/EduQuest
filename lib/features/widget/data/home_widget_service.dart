import 'package:eduquest/shared/config/env.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  Future<bool> canPin() async {
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  Future<void> requestPin() async {
    await HomeWidget.requestPinWidget(androidName: Env.homeWidgetAndroidName);
  }

  Future<void> update({
    required String title,
    required String focusLabel,
    required String focusValue,
    String? footer,
  }) async {
    await HomeWidget.saveWidgetData<String>('eduquest_title', title);
    await HomeWidget.saveWidgetData<String>('eduquest_focus_label', focusLabel);
    await HomeWidget.saveWidgetData<String>('eduquest_focus_value', focusValue);
    await HomeWidget.saveWidgetData<String>('eduquest_footer', footer ?? '');
    await HomeWidget.updateWidget(
      androidName: Env.homeWidgetAndroidName,
      iOSName: Env.homeWidgetIosName,
    );
  }
}
