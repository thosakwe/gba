import 'dart:typed_data';

class MMU {
  final ByteData _byteData = new ByteData.view(new Uint16List(65536).buffer);

  MMUBank _permanentROMBank,
      _switchableROMBank,
      _videoRAM,
      _switchableExternalROMBank,
      _workingRAMBank0,
      _workingRAMBank1,
      _spriteAttributeTable,
      _deviceMappings,
      _highRAMArea;

  MMUBank _bank(int start, int end) =>
      new MMUBank(new ByteData.view(_byteData.buffer, start, end - start));

  ByteBuffer get buffer => _byteData.buffer;

  ByteData get byteData => _byteData;

  MMUBank get permanentROMBank => _permanentROMBank ??= _bank(0x0000, 0x3FFF);

  MMUBank get switchableROMBank => _switchableROMBank ??= _bank(0x4000, 0x7FFF);

  MMUBank get videoRAM => _videoRAM ??= _bank(0x8000, 0x9FFF);

  MMUBank get switchableExternalROMBank =>
      _switchableExternalROMBank ??= _bank(0xA000, 0xBFFF);

  MMUBank get workingRAMBank0 => _workingRAMBank0 ??= _bank(0xC000, 0xCFFF);

  MMUBank get workingRAMBank1 => _workingRAMBank1 ??= _bank(0xD000, 0xDFFF);

  MMUBank get spriteAttributeTable =>
      _spriteAttributeTable ??= _bank(0xFE00, 0xFEFF);

  MMUBank get deviceMappings => _deviceMappings ??= _bank(0xFF00, 0xFF7F);

  MMUBank get highRAMArea => _highRAMArea ??= _bank(0xFF80, 0xFFFE);

  int get interruptEnableRegister => _byteData.getUint8(0xFFFF);
}

class MMUBank {
  final ByteData _byteData;

  MMUBank(this._byteData);

  void write(ByteBuffer b) {
    var bb = b.asByteData();

    for (int i = 0; i < b.lengthInBytes && i < _byteData.lengthInBytes; i++) {
      _byteData.setUint8(i, bb.getUint8(i));
    }
  }
}
