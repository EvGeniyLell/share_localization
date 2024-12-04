// import 'dart:io';
//
// import 'package:meta/meta.dart';
//
// import 'package:flutter_code_organizer/src/common/utils/files.dart';
//
// /// IOManager is a class that provides methods to read and write files.
// /// It also provides a method to get files according to parameters.
// ///
// /// This class is a singleton and should be used to access the file system.
// /// It can be mocked for testing purposes.
// /// To mock it, you can create a new instance and assign
// /// it to the [instance] field.
// class IOManager {
//   @visibleForTesting
//   static IOManager instance = const IOManager.private();
//
//   factory IOManager() => instance;
//
//   const IOManager.private();
//
//   String readFile(File file) => file.readAsStringSync();
//
//   void writeFile(File file, String content) => file.writeAsStringSync(content);
//
//   /// Get files according to parameters.
//   /// - [currentPath] is the path to start the search.
//   /// - [allowedDirectories] is the list of directories to allow.
//   /// If empty all directories are allowed.
//   /// - [allowedExtensions] is the list of extensions to allow.
//   /// If empty all extensions are allowed.
//   static Iterable<File> getFiles(
//     String currentPath, {
//     List<String> allowedDirectories = const [],
//     List<String> allowedExtensions = const [],
//   }) {
//     return Directory(currentPath)
//         .listSync(recursive: true)
//         .whereType<File>()
//         .where((file) {
//       bool fileAllowed = true;
//
//       if (fileAllowed && allowedExtensions.isNotEmpty) {
//         fileAllowed = allowedExtensions.any((ext) {
//           return file.path.endsWith(ext);
//         });
//       }
//
//       if (fileAllowed && allowedDirectories.isNotEmpty) {
//         fileAllowed = allowedDirectories.any((pattern) {
//           final path = file.getRelativePath(currentPath);
//           return RegExp(pattern).hasMatch(path);
//         });
//       }
//
//       return fileAllowed;
//     });
//   }
// }
