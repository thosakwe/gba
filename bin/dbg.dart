import 'dart:io';
import 'dart:typed_data';
import 'package:cli_repl/cli_repl.dart';
import 'package:gba/gba.dart';
import 'package:logging/logging.dart';

main(List<String> args) async {
  var breakpoints = <int>[];
  var logger = new Logger('gba')..onRecord.listen(print);
  Uint8List bytes;
  Gameboy gba;

  print('GBA emulator - Tobechukwu Osakwe');
  print('Type "help" for more information.');

  if (args.length >= 1) {
    bytes = new Uint8List.fromList(await new File(args[0]).readAsBytes());
    print('Loaded ROM "${args[0]}".');
  }

  var repl = new Repl(prompt: 'gba) ', continuation: '...');

  await for (var line in repl.runAsync()) {
    var split = line
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (split.isEmpty) continue;
    var cmd = split[0], args = split.skip(1).toList();

    switch (cmd) {
      case 'help':
        print('* brk                          Add a breakpoint.');
        print('* disasm [start] [end]         Disassemble the current ROM.');
        print('* help                         Print this help information.');
        print('* load <file>                  Load a GBA ROM.');
        print('* run                          Start the emulator.');
        print('* stop                         Stop running the emulator.');
        print('* quit                         Exit immediately.');
        break;
      case 'brk':
        if (args.isEmpty) {
          print('Missing argument. Type "help" for usage info.');
        } else {
          breakpoints.addAll(args.map(int.parse));
        }
        break;
      case 'disasm':
        if (bytes.isEmpty) {
          print('No ROM has been loaded.');
        } else {
          var pc = new ProgramCounter(bytes);
          int start = 0, end = bytes.lengthInBytes - 1;
          if (args.length >= 1) start = int.parse(args[0]);
          if (args.length >= 2) end = int.parse(args[1]);
          pc.seek(start);

          stdout
            ..write('Offset'.padRight(8))
            ..write('    ')
            ..write('Opcode'.padRight(8))
            ..write('    ')
            ..write('Operand'.padRight(8))
            ..writeln()
            ..writeln();

          while (!pc.done && pc.position >= start && pc.position <= end) {
            var inst = parseInstruction(pc);
            stdout
              ..write(pc.position.toRadixString(16).padLeft(8, '0'))
              ..write('    ')
              ..write(inst.name.padRight(8));

            if (inst.operand != null) {
              stdout
                ..write('    ')
                ..write(inst.operand.toRadixString(16).padLeft(8, '0'));
            }

            stdout.writeln();
          }
        }
        break;
      case 'load':
        if (args.isEmpty) {
          print('Missing argument. Type "help" for usage info.');
        } else if (gba != null) {
          print('Emulator is already running.');
        } else {
          bytes = new Uint8List.fromList(await new File(args[0]).readAsBytes());
        }
        break;
      case 'stop':
        if (gba == null)
          print('Emulator is not running.');
        else
          gba = null;
        break;
      case 'quit':
        exit(0);
        break;
      default:
        print('Unknown command "$cmd". Type "help" for usage info.');
        break;
    }
  }
}
