enum AuthGateMode {
  optional('optional'),
  featureScoped('feature_scoped'),
  required('required');

  const AuthGateMode(this.value);

  final String value;

  static AuthGateMode fromString(String input) {
    switch (input.toLowerCase().trim()) {
      case 'optional':
      case 'none':
      case 'off':
        return AuthGateMode.optional;
      case 'feature_scoped':
      case 'feature':
      case 'features':
      case 'scoped':
      case 'rewards_only':
      case 'reward':
      case 'rewards':
      case 'claim_only':
        return AuthGateMode.featureScoped;
      case 'required':
      case 'all':
      case 'force':
        return AuthGateMode.required;
    }

    return AuthGateMode.featureScoped;
  }
}
