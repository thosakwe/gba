import 'dart:typed_data';

class Stack {
  final Uint16List _data;

  ByteData _byteData;
  int sp = 0;

  Stack(int size) : _data = new Uint16List(size) {
    _byteData = new ByteData.view(_data.buffer);
  }

  int pop8() {
    var result = _byteData.getUint8(sp--);
    return result;
  }

  int pop16() {
    var result = _byteData.getUint16(sp, Endian.little);
    if (sp > 1) sp -= 2;
    return result;
  }

  void push8(int value) {
    //if (sp < _data.length - 1) sp++;
    //_data[sp] = value;
    //if (sp < _byteData.lengthInBytes - 3) sp++;
    //sp = (sp + 1).clamp(sp, _byteData.lengthInBytes - 2);
    _byteData.setUint8(sp++, value);
  }

  void push16(int value) {
    //if (sp < _data.length - 1) sp++;
    //_data[sp] = value;
    //if (sp < _byteData.lengthInBytes - 3) sp++;
    //sp = (sp + 1).clamp(sp, _byteData.lengthInBytes - 2);
    _byteData.setUint16(sp, value, Endian.little);
    sp += 2;
  }

  @override
  String toString() {
    return 'Stack (${_byteData.lengthInBytes} byte(s)):\n' +
        '  Pointer: $sp\n' +
        'Data: $_data';
  }
}
