import 'package:charcode/ascii.dart';
import 'program_counter.dart';
import 'gameboy.dart';
import 'emulator.dart';
import 'parse_instruction.dart';
import 'registers.dart';
import 'stack.dart';

class CPU {
  final List<int> breakPoints = [];
  final Registers registers = new Registers();
  final Gameboy gba;
  final ProgramCounter pc;
  final Stack stack;
  final EmulatorState state;
  int instructionPointer = 0;

  CPU(this.gba, this.state, this.pc) : stack = new Stack(state.stackSize);

  static String hex(int n) {
    return n.toRadixString(10);
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

  void callRoutine(int offset, int returnTo) {
    stack.push16(returnTo);
    jump(offset);
  }

  void jump(int offset) {
    pc.seek(offset);
  }

  int loop() {
    var done = false;

    while (!done) {
      var pos = pc.position, peek = pc.peek;
      var inst = parseInstruction(pc);

      if (breakPoints.contains(pc.position)) {
        state.writeln(
            'REACHED BREAKPOINT: 0x' + pos.toRadixString(16).padLeft(8, '0'));
        state.writeln('Instruction: $inst');
        state.writeln('Peek: $peek');
        dump();

        state.writeln('Hit ENTER to continue. Type "quit" to exit.');

        var line = state.readLineSync().trim();

        if (line == 'quit') break;
      }

      /*
      if (inst.operand != null)
        state.writeln('${inst.name} with ${inst.operand}');
      else
        state.writeln(inst.name);
      */

      switch (inst.name) {
        case 'ADC A,D':
          var value = registers.D;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.cf = !(registers.A += value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.cf = (registers.A += value).isNegative;
          } else {
            registers.A += pc.uint8;
          }
          break;
        case 'ADC A,n':
          var value = pc.uint8;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.cf = !(registers.A += value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.cf = (registers.A += value).isNegative;
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
        case 'AND A':
          registers.flags.zf = (registers.A &= registers.A) == 0;
          registers.flags.h = true;
          break;
        case 'AND D':
          registers.flags.zf = (registers.A &= registers.D) == 0;
          registers.flags.h = true;
          break;
        case 'AND E':
          registers.flags.zf = (registers.A &= registers.E) == 0;
          registers.flags.h = true;
          break;
        case 'CP (HL)':
          registers.flags.zf = pc.uint8At(registers.HL) == registers.A;
          break;
        case 'CPL':
          // Complement accumulator.
          registers.F = 0;
          registers.flags.n = true;
          registers.flags.h = true;
          break;
        case 'DAA':
          // Adjust A for BCD addition
          // Get all decimal digits, then add them.
          // Because I'm lazy, just do this via strings.
          var digits = registers.A
              .toString()
              .codeUnits
              .map((ch) => ch - $0)
              .toList()
              .reversed
              .toList();
          registers.A = 0;

          for (int i = digits.length - 1; i >= 0; i--) {
            registers.A |= digits[i] << i;
          }
          break;
        case 'DEC E':
          registers.E--;
          break;
        case 'HALT':
          // TODO: Any purpose in enabling low-power mode?
          break;
        case 'INC BC':
          registers.BC++;
          break;
        case 'INC DE':
          registers.DE++;
          break;
        case 'INC HL':
          registers.HL++;
          break;
        case 'JP Z,nn':
          var offset = pc.uint16;
          if (!registers.flags.zf) jump(offset);
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
        case 'LD B,(HL)':
          registers.B = pc.uint8At(registers.HL);
          break;
        case 'LD C,D':
          registers.C = registers.D;
          break;
        case 'LD C,L':
          registers.C = registers.L;
          break;
        case 'LD D,C':
          registers.D = registers.C;
          break;
        case 'LD D,(HL)':
          registers.D = gba.mmu.byteData.getUint8(registers.HL);
          break;
        case 'LD DE,nn':
          registers.DE = pc.uint16;
          break;
        case 'LD E,B':
          registers.E = registers.B;
          break;
        case 'LD (HL),D':
          gba.mmu.byteData.setUint8(registers.HL, registers.D);
          break;
        case 'LD (HL),E':
          gba.mmu.byteData.setUint8(registers.HL, registers.E);
          break;
        case 'LD HL,nn':
          var data = pc.uint16;
          registers.HL = data;
          break;
        case 'LDH (n),A':
          // Save A at address pointed to by (FF00h + 8-bit immediate)
          var offset = 0xFF00 + pc.uint8;
          gba.mmu.byteData.setUint8(offset, registers.A);
          break;
        case 'LDHL SP,d':
          // Add signed 8-bit immediate to SP and save result in HL
          registers.HL = stack.sp += pc.uint8;
          break;
        case 'LD L,C':
          registers.L = registers.C;
          break;
        case 'LD L,n':
          registers.L = pc.uint8;
          break;
        case 'LD SP,nn':
          // TODO: Shouldn't this be 16-bit?
          stack.sp = pc.uint16;
          break;
        case 'NOP':
          break;
        case 'POP BC':
          registers.BC = stack.pop16();
          break;
        case 'POP HL':
          registers.HL = stack.pop16();
          break;
        case 'RET NZ':
          if (registers.flags.zf) jump(stack.pop16());
          break;
        case 'RRC A':
          // Rotate A right with carry
          // TODO: Carry?
          registers.A = (registers.A << 1) & (registers.A >> 7);
          break;
        case 'RST 0':
          // Call routine at address 0000h
          callRoutine(0x0000, pos);
          break;
        case 'RST 38':
          // Call routine at address 0038h
          callRoutine(0x0038, pos);
          break;
        case 'SBC A,A':
          var value = registers.A;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.cf = !(registers.A -= value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.cf = (registers.A -= value).isNegative;
          } else {
            registers.A -= pc.uint8;
          }
          break;
        case 'SBC A,B':
          var value = registers.B;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.cf = !(registers.A -= value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.cf = (registers.A -= value).isNegative;
          } else {
            registers.A -= pc.uint8;
          }
          break;
        case 'SBC A,D':
          var value = registers.D;
          if (registers.A.isNegative && value.isNegative) {
            registers.flags.cf = !(registers.A -= value).isNegative;
          } else if (!registers.A.isNegative && !value.isNegative) {
            registers.flags.cf = (registers.A -= value).isNegative;
          } else {
            registers.A -= pc.uint8;
          }
          break;
        case 'SUB A,A':
          registers.A -= registers.A;
          break;
        case 'SUB A,E':
          registers.A -= registers.E;
          break;
        case 'SUB A,H':
          registers.A -= registers.H;
          break;
        case 'STOP':
          state.writeln('Program issued STOP command. Exiting.');
          //done = true;
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
