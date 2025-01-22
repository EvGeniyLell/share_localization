class GeneralLocalization {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "General", bundle: .sdkResource)
  }
  
  /// This a body of error notification message.
  ///
  /// In en, this message translates to:
  /// **'The {file_name} has size {current_size}, it is biggest then maximum {maximum_size}.'**
  static func fileSizeErrorBody(_ fileName: String, _ currentSize: Double, _ maximumSize: Double) -> String {
    l("fileSizeErrorBody\(fileName)\(currentSize)\(maximumSize)")
  }

  /// This is a attention message for file size.
  ///
  /// In en, this message translates to:
  /// **'File should be less or equal to {maximum_size} MB.'**
  static func fileSizeAttention(_ maximumSize: Int) -> String {
    l("fileSizeAttention\(maximumSize)")
  }

  /// This is a title for file size error screen
  ///
  /// In en, this message translates to:
  /// **'Attention! The file size is too big.'**
  static var fileSizeTitle : String {
    l("fileSizeTitle")
  }  
}
