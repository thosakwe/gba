import 'program_counter.dart';
import 'emulator.dart';
import 'parse_instruction.dart';
import 'registers.dart';
import 'stack.dart';

class CPU {
  final Registers registers = new Registers();
  final ProgramCounter pc;
  final Stack stack;
  final EmulatorState state;
  int instructionPointer = 0;

  CPU(this.state)
      : pc = new ProgramCounter(state.bytes),
        stack = new Stack(state.stackSize);

  static String hex(int n) {
    var b = new StringBuffer();

    for (int i = 7; i >= 0; i--) {
      b.write(n >> i);
    }

    return b.toString();
  }

  void dump() {
    var w = state.writeln;
    w('DUMPING GBA EMULATOR:');
    w('Stack: $stack');
    w('\n');
    w('Registers: ');
    w('A: ${hex(registers.A)}');
    w('B: ${hex(registers.B)}');
    w('C: ${hex(registers.C)}');
    w('D: ${hex(registers.D)}');
    w('E: ${hex(registers.E)}');
    w('H: ${hex(registers.H)}');
    w('L: ${hex(registers.L)}');
    w('\n');
    w('FLAGS:');
    w('byte: ${hex(registers.F)}');
    w('CF: ${registers.flags.cf}');
    w('ZF: ${registers.flags.zf}');
  }

  void jump(int offset) {
    pc.seek(offset);
  }

  int loop() {
    var done = false;

    while (!done) {
      var inst = parseInstruction(pc);

      if (inst.operand != null)
        print('${inst.name} with ${inst.operand}');
      else
        print(inst.name);

      switch (inst.name) {
        case 'ADC A,n':
          var value = pc.uint8;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.zf = !(registers.A += value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.zf = (registers.A += value).isNegative;
          } else {
            registers.A += pc.uint8;
          }
          break;
        case 'ADD A,C':
          registers.A += registers.C;
          break;
        case 'ADD A,D':
          registers.A += registers.D;
          break;
        case 'ADD A,H':
          registers.A += registers.H;
          break;
        case 'ADD HL,BC':
          registers.HL += registers.BC;
          break;
        case 'ADD HL,DE':
          registers.HL += registers.DE;
          break;
        case 'AND D':
          registers.A &= registers.D;
          break;
        case 'CP (HL)':
          registers.flags.zf = pc.uint8At(registers.HL) != registers.A;
          break;
        case 'LD (nn),A':
          var offset = pc.uint16;
          pc.at(offset).setUint8(0, registers.A);
          break;
        case 'LD A,(BC)':
          registers.A = pc.uint8At(registers.BC);
          break;
        case 'LD A,A':
          registers.A = registers.A;
          break;
        case 'LD D,C':
          registers.D = registers.C;
          break;
        case 'LD DE,nn':
          registers.DE = pc.uint16;
          break;
        case 'LD HL,nn':
          var data = pc.uint16;
          registers.HL = data;
          break;
        case 'LD L,C':
          registers.L = registers.C;
          break;
        case 'LD L,n':
          registers.L = pc.uint8;
          break;
        case 'NOP':
          break;
        case 'RET NZ':
          if (!registers.flags.zf) jump(stack.pop());
          break;
        case 'SBC A,B':
          var value = registers.B;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.zf = !(registers.A -= value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.zf = (registers.A -= value).isNegative;
          } else {
            registers.A -= pc.uint8;
          }
          break;
        case 'SBC A,D':
          var value = registers.D;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.zf = !(registers.A -= value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.zf = (registers.A -= value).isNegative;
          } else {
            registers.A -= pc.uint8;
          }
          break;
        case 'SUB A,E':
          registers.A -= registers.E;
          break;
        case 'STOP':
          state.writeln('Program issued STOP command. Exiting.');
          done = true;
          break;
        case 'XOR (HL)':
          registers.A ^= pc.uint8At(registers.HL);
          break;
        case 'XOR L':
          registers.A ^= registers.L;
          break;
        case 'XX':
          break;
        default:
          throw "Unsupported opcode: '${inst.name}' (0x" +
              inst.opcode.toRadixString(16) +
              ")";
      }
    }

    return 0;
  }
}
