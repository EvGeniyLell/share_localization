internal class TestFeatureALocalizationLocalization {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "TestFeatureALocalization", bundle: .testBundle)
  }

  /// This a body of login message.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}, your password is {password}'**
  static func loginMessage(_ username: String, _ password: String) -> String {
    l("loginMessage\(username)\(password)")
  }

  /// This is a title for login screen.
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  static var loginTitle : String {
    l("loginTitle")
  }
}