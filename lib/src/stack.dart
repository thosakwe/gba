import 'dart:typed_data';

class Stack {
  final ByteData _byteData;
  int sp = 0;

  Stack(int size) : _byteData = new ByteData.view(new Int16List(size).buffer);

  int pop() {
    var result = _byteData.getUint16(sp);
    if (sp > 0) sp--;
    return result;
  }

  void push(int value) {
    _byteData.setUint16(sp++, value);
  }

  @override
  String toString() {
    return 'Stack (${_byteData.lengthInBytes} byte(s)):\n' +
        '  Pointer: $sp\n' +
        'Data: ${new Int16List.view(_byteData.buffer)}';
  }
}
