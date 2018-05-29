import 'dart:typed_data';
import 'package:logging/logging.dart';

class EmulatorState {
  int stackSize = 256;
  Uint8List bytes;
  void Function() cls;
  void Function(Object) write, writeln;

  EmulatorState();

  factory EmulatorState.forLogger(Logger logger) {
    return new EmulatorState()
      ..cls = () => null
        ..write = logger.info
        ..writeln = logger.info;
  }
}
