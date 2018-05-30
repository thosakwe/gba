import 'cpu.dart';
import 'emulator.dart';
import 'gpu.dart';
import 'mmu.dart';
import 'program_counter.dart';

class Gameboy {
  final MMU mmu = new MMU();
  final GPU gpu;
  final EmulatorState state;
  CPU _cpu;

  Gameboy(this.state, this.gpu) {
    // Load the first 16kb of the program into memory...
    mmu.permanentROMBank.write(state.bytes.buffer);

    // Program starts at 0x0100;
    var pc = new ProgramCounter(mmu.buffer);
    pc.seek(0x0100);

    _cpu = new CPU(this, state, pc);
  }

  CPU get cpu => _cpu;
}
