class AuthFeatureRule {
  const AuthFeatureRule({required this.featureId, required this.routePrefixes});

  final String featureId;
  final Set<String> routePrefixes;

  bool matchesPath(String path) {
    for (final prefix in routePrefixes) {
      if (path.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }
}

class AuthFeatureRegistry {
  const AuthFeatureRegistry({required this.rules});

  final Set<AuthFeatureRule> rules;

  Set<String> resolveFeatureIdsForPath(String path) {
    final featureIds = <String>{};
    for (final rule in rules) {
      if (rule.matchesPath(path)) {
        featureIds.add(rule.featureId);
      }
    }

    return featureIds;
  }
}
