import 'package:binary/binary.dart';
import 'registers.dart';

class Flags {
  final Registers registers;

  Flags(this.registers);

  int get _value => registers.F;

  void set _value(int value) => registers.F = value;

  bool get cf => uint8.isSet(_value, 4);

  void set cf(bool value) {
    if (value)
      _value = uint8.set(_value, 4);
    else
      _value = uint8.clear(_value, 4);
  }

  bool get h => uint8.isSet(_value, 5);

  void set h(bool value) {
    if (value)
      _value = uint8.set(_value, 5);
    else
      _value = uint8.clear(_value, 5);
  }

  bool get n => uint8.isSet(_value, 6);

  void set n(bool value) {
    if (value)
      _value = uint8.set(_value, 6);
    else
      _value = uint8.clear(_value, 6);
  }

  bool get zf => uint8.isSet(_value, 7);

  void set zf(bool value) {
    if (value)
      _value = uint8.set(_value, 7);
    else
      _value = uint8.clear(_value, 7);
  }
}
