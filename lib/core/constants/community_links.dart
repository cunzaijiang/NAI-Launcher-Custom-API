/// Public project links exposed consistently across desktop and mobile UI.
abstract final class CommunityLinks {
  static const qq = 'https://qm.qq.com/q/jY8Pshi5os';

  /// Discord membership is still required by the Discord sharing service.
  static const discord = 'https://discord.gg/R48n6GwXzD';
  static const github =
      'https://github.com/cunzaijiang/NAI-Launcher-Custom-API';
  static const releases = '$github/releases';

  /// This fork publishes independent prereleases, not upstream signed updates.
  /// Keep automatic discovery/installation disabled for every account route.
  static const isCustomApiDistribution = true;
}
