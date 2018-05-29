import 'dart:typed_data';

class MMU {
  final ByteData _byteData = new ByteData.view(new Uint8List(65536).buffer);
}
