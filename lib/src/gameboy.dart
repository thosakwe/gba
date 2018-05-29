import 'cpu.dart';
import 'emulator.dart';
import 'gpu.dart';
import 'mmu.dart';

class Gameboy {
  final MMU mmu = new MMU();
  final CPU cpu;
  final GPU gpu;
  final EmulatorState state;

  Gameboy(this.state, this.gpu) : cpu = new CPU(state);
}
