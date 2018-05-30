import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:args/args.dart';
import 'package:cli_repl/cli_repl.dart';
import 'package:gba/gba.dart';
import 'package:gba/gba_io.dart';
import 'package:logging/logging.dart';

final ArgParser argParser = new ArgParser()
  ..addFlag('help',
      abbr: 'h', negatable: false, help: 'Print this usage information.')
  ..addMultiOption('command', abbr: 'c', help: 'Command(s) to run on startup.');

main(List<String> args) async {
  try {
    var argResults = argParser.parse(args);

    if (argResults['help']) {
      printUsage(stdout);
      exit(0);
      return;
    }

    var breakPoints = <int>[];
    var logger = new Logger('gba')..onRecord.listen(print);
    Uint8List bytes = new Uint8List(0);
    Gameboy gba;

    print('GBA emulator - Tobechukwu Osakwe');
    print('Type "help" for more information.');

    if (argResults.rest.length >= 1) {
      bytes = new Uint8List.fromList(
          await new File(argResults.rest[0]).readAsBytes());
      print('Loaded ROM "${argResults.rest[0]}".');
    }

    handleCommand(String cmd, List<String> args) async {
      switch (cmd) {
        case 'help':
          print('* brk                          Add a breakpoint.');
          print('* brk-all                      Break on all commands.');
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
            breakPoints.addAll(args.map((s) => int.tryParse(s, radix: 16)));
          }
          break;
        case 'brk-all':
          if (bytes.isEmpty) {
            print('No ROM has been loaded.');
          } else {
            breakPoints.addAll(new List.generate(bytes.length, (i) => i));
          }
          break;
        case 'disasm':
          if (bytes.isEmpty) {
            print('No ROM has been loaded.');
          } else {
            var pc = new ProgramCounter(bytes.buffer);
            int start = 0, end = bytes.lengthInBytes - 1;
            if (args.length >= 1) start = int.parse(args[0], radix: 16);
            if (args.length >= 2) end = int.parse(args[1], radix: 16);
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
              var pos = pc.position;
              var inst = parseInstruction(pc);
              stdout
                ..write(pos.toRadixString(16).padLeft(8, '0'))
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
            bytes =
                new Uint8List.fromList(await new File(args[0]).readAsBytes());
          }
          break;
        case 'run':
          if (bytes.isEmpty) {
            print('No ROM has been loaded.');
          } else {
            gba = new Gameboy(
              new EmulatorState.forLogger(logger)
                ..bytes = bytes
                ..readLineSync = stdin.readLineSync,
              new InvisibleGPU(),
            );
            gba.cpu.breakPoints.addAll(breakPoints);
            gba.cpu.loop();
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

    handleLine(String line) async {
      var split = line
          .split(' ')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (split.isEmpty) return null;
      var cmd = split[0], args = split.skip(1).toList();
      return await handleCommand(cmd, args);
    }

    var repl = new Repl(prompt: 'gba) ', continuation: '...');

    for (var command in argResults['command']) {
      for (var line in command.split(';')) await handleLine(line);
    }

    for (var line in repl.run()) {
      await handleLine(line);
    }
  } on ArgParserException catch (e) {
    stderr.writeln('fatal error: ${e.message}');
    printUsage(stderr);
    exit(1);
  }
}

void printUsage(IOSink sink) {
  sink
    ..writeln('usage: dbg.dart [options...] [filename]')
    ..writeln()
    ..writeln(argParser.usage);
}
