import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/constants/community_links.dart';

void main() {
  test('community navigation uses QQ without changing Discord sharing', () {
    expect(CommunityLinks.qq, 'https://qm.qq.com/q/jY8Pshi5os');
    expect(CommunityLinks.discord, 'https://discord.gg/R48n6GwXzD');

    for (final path in [
      'lib/presentation/widgets/navigation/main_nav_rail.dart',
      'lib/presentation/router/mobile_more_panel.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('CommunityLinks.qq'), reason: path);
      expect(source, contains('QQLogo('), reason: path);
      expect(source, isNot(contains('CommunityLinks.discord')), reason: path);
      expect(source, isNot(contains('Icons.discord')), reason: path);
      expect(source, contains('LaunchMode.externalApplication'), reason: path);
    }

    expect(
      File('lib/data/services/discord_share_service.dart').readAsStringSync(),
      contains('const discordCommunityUrl = CommunityLinks.discord;'),
    );
    expect(File('assets/icons/qq.png').existsSync(), isTrue);
  });

  test('community labels identify QQ in all four locales', () {
    for (final locale in ['en', 'zh', 'zh_Hant', 'ja']) {
      final arb =
          jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      for (final key in ['nav_discordCommunity', 'nav_joinDiscord']) {
        expect(arb[key], contains('QQ'), reason: '$locale: $key');
        expect(arb[key], isNot(contains('Discord')), reason: '$locale: $key');
      }
    }
  });
}
