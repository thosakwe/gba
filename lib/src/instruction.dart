class Instruction {
  final String name;
  final int opcode, operand;

  Instruction(this.name, this.opcode, this.operand);

  @override
  String toString() {
    var b = new StringBuffer()
      ..write(name.padRight(12))
      ..write('    ')
      ..write('Opcode: 0x')
      ..write(opcode.toRadixString(16).padLeft(8, '0'));

    if (operand != null)
      b
        ..write('    Operand: ')
        ..write(operand.toRadixString(16).padLeft(8, '0'));

    return b.toString();
  }
}
