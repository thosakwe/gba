import 'dart:typed_data';

class ProgramCounter {
  final ByteBuffer _bytes;
  int _index = 0;

  ProgramCounter(this._bytes);

  get peek => _index >= _bytes.lengthInBytes - 1
      ? '<eof>'
      : '0x' + byteData.getUint8(_index + 1).toRadixString(16);

  bool get done => _index >= _bytes.lengthInBytes;

  int get position => _index;

  ByteData get byteData => new ByteData.view(_bytes, _index);

  double get float32 => byteData.getFloat32(0, Endian.little);

  double get float64 => byteData.getFloat64(0, Endian.little);

  int get int8 => advance(1, (byteData) => byteData.getInt8(0));

  int get int16 =>
      advance(2, (byteData) => byteData.getInt16(0, Endian.little));

  int get int32 =>
      advance(4, (byteData) => byteData.getInt32(0, Endian.little));

  int get int64 =>
      advance(8, (byteData) => byteData.getInt64(0, Endian.little));

  int get uint8 => advance(1, (byteData) => byteData.getUint8(0));

  int get uint16 =>
      advance(2, (byteData) => byteData.getUint16(0, Endian.little));

  int get uint32 =>
      advance(4, (byteData) => byteData.getUint32(0, Endian.little));

  int get uint64 =>
      advance(8, (byteData) => byteData.getUint64(0, Endian.little));

  ByteData at(int idx) => new ByteData.view(_bytes, idx);

  int uint8At(int idx) => at(idx).getUint8(0);

  T advance<T>(int n, T Function(ByteData) f) {
    var result = f(byteData);
    _index += n;
    return result;
  }

  void seek(int pos) {
    _index = pos.clamp(0, _bytes.lengthInBytes - 1);
  }
}
