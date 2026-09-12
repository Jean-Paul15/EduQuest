import 'package:eduquest/shared/deeplink/app_deep_link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scheme custom ruachedu:// reste supporte (tab via host)', () {
    final cmd = AppDeepLinkParser.fromRaw('ruachedu://home?kind=ticket');
    expect(cmd?.tabIndex, 0);
    expect(cmd?.kind, 'ticket');
  });

  test('lien universel https://edu.ruachnova.com/<tab> reconnu', () {
    final cmd = AppDeepLinkParser.fromRaw('https://edu.ruachnova.com/hub?kind=event');
    expect(cmd?.tabIndex, 3);
    expect(cmd?.kind, 'event');
  });

  test('login-callback ignore sur les deux formes', () {
    expect(AppDeepLinkParser.fromRaw('ruachedu://login-callback'), isNull);
    expect(AppDeepLinkParser.fromRaw('https://edu.ruachnova.com/login-callback'), isNull);
  });

  test('host https different de edu.ruachnova.com rejete', () {
    expect(AppDeepLinkParser.fromRaw('https://evil.example.com/home'), isNull);
  });

  test('scheme inconnu rejete', () {
    expect(AppDeepLinkParser.fromRaw('mailto:test@example.com'), isNull);
  });
}
