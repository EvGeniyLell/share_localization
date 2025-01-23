class FeatureALocalization {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "FeatureA", bundle: .sdkResource)
  }
  
  /// This a body of login message.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}, your password is {password}'**
  static func loginMessage(_ username: String, _ password: String) -> String {
    l("loginMessage\(username)\(password)")
  }

  /// This is a title for login screen
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  static var loginTitle : String {
    l("loginTitle")
  }

  /// This is a login button on login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  static var loginButton : String {
    l("loginButton")
  }  
}
