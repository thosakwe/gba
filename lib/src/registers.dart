import 'dart:typed_data';
import 'flags.dart';

class Registers {
  final ByteData _byteData =
      new ByteData.view(new Uint8List(8).buffer); // 16 8-bit registers?

  Flags _flags;

  Flags get flags => _flags ??= new Flags(this);

  int get A => _byteData.getUint8(0);

  void set A(int value) => _byteData.setUint8(0, value);

  int get B => _byteData.getUint8(1);

  int get BC => _byteData.getUint16(1, Endian.little);

  void set B(int value) => _byteData.setUint8(1, value);

  void set BC(int value) => _byteData.setUint16(1, value);

  int get C => _byteData.getUint8(2);

  void set C(int value) => _byteData.setUint8(2, value);

  int get D => _byteData.getUint8(3);

  int get DE => _byteData.getUint16(3, Endian.little);

  void set D(int value) => _byteData.setUint8(3, value);

  void set DE(int value) => _byteData.setUint16(3, value, Endian.little);

  int get E => _byteData.getUint8(4);

  void set E(int value) => _byteData.setUint8(4, value);

  int get F => _byteData.getUint8(5);

  void set F(int value) => _byteData.setUint8(5, value);

  int get H => _byteData.getUint8(6);

  int get HL => _byteData.getUint16(6, Endian.little);

  void set H(int value) => _byteData.setUint8(6, value);

  void set HL(int value) => _byteData.setUint16(6, value, Endian.little);

  int get L => _byteData.getUint8(7);

  void set L(int value) => _byteData.setUint8(7, value);
}
