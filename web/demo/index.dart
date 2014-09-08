library ace_editor_demo;

import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.onRecord.forEach((record) => print(record.toString()));

  initPolymer();
}