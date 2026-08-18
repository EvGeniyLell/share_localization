import 'dart:io';

import 'package:share_localization/share_localization.dart'
    as share_localization;

Future<void> main(List<String> arguments) async {
  final success = await share_localization.run();
  if (!success) {
    exit(1);
  }
}
