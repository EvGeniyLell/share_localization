internal class TestNumbersLocalization {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "TestNumbersLocalization", bundle: .testBundle)
  }

  /// This is a report about a file.
  ///
  /// In en, this message translates to:
  /// **'File {title} has {pages} pages and weighs {size} MB'**
  static func fileReport(_ title: String, _ size: Double, _ pages: Int) -> String {
    l("fileReport\(title)\(size)\(pages)")
  }
}
