import 'dart:convert';
import 'dart:io';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:html/parser.dart' as html;
import 'package:path/path.dart' as p;

main() async {
  var opcodeMap = new File.fromUri(p.toUri(p.absolute(p.join(
    p.dirname(
      p.fromUri(Platform.script),
    ),
    'opcode_map.html',
  ))));

  if (!await opcodeMap.exists()) {
    var uri = 'http://imrannazar.com/Gameboy-Z80-Opcode-Map';
    print('Downloading $uri...');
    var client = new HttpClient();
    var rq = await client.openUrl('GET', Uri.parse(uri));
    var rs = await rq.close();
    await opcodeMap.create(recursive: true);
    await rs.pipe(opcodeMap.openWrite());
    client.close(force: true);
  }

  print('Reading ${opcodeMap.absolute.path}...');
  var contents = await opcodeMap.readAsString();
  var doc = html.parse(contents, sourceUrl: opcodeMap.absolute.path);

  var oneByte = doc.querySelectorAll('table')[0];

  var library = new Library((lib) {
    lib.body.addAll([
      //new Code('// GENERATED CODE. DO NOT MODIFY BY HAND.'),
      new Directive.import('program_counter.dart'),
      new Directive.import('instruction.dart'),
    ]);

    lib.body.add(new Method((method) {
      method
        ..name = 'parseInstruction'
        ..returns = refer('Instruction')
        ..requiredParameters.add(new Parameter((b) => b
          ..name = 'reader'
          ..type = refer('ProgramCounter')))
        ..body = new Block((block) {
          // Loop through each one-byte instruction.
          var oneByteInstrs = <int, String>{};

          int i = 0;
          for (var $tr in oneByte.querySelectorAll('tr').skip(1)) {
            int j = 0;

            for (var $td in $tr.querySelectorAll('td').skip(1)) {
              var opcode = (i * 16) + j++;
              oneByteInstrs[opcode] = $td.text.trim();
            }

            i++;
          }

          lib.body.add(
            literalConstMap(oneByteInstrs)
                .assignConst(
                  'oneByteInstrs',
                  new TypeReference((b) => b
                    ..symbol = 'Map'
                    ..types.addAll([refer('int', 'String')])),
                )
                .statement,
          );

          block.statements.add(new Code('''
          var op = reader.uint8;
          
          if (op == 0xCB)
            throw 'Prefix!';
          
          for (var key in oneByteInstrs.keys) {
            if (op == key)
              return new Instruction(
                oneByteInstrs[key],
                key,
                null,
              );
          }
          
          throw (
            "Malformed opcode: 0x"
            + op.toRadixString(16)
          );
          '''));
        });
    }));
  });

  var dartCode =
      new DartFormatter().format(library.accept(new DartEmitter()).toString());
  var path = p.absolute(
    p.join(
      p.dirname(p.fromUri(Platform.script)),
      '..',
      'lib',
      'src',
      'parse_instruction.dart',
    ),
  );

  var file = new File.fromUri(p.toUri(path));
  await file.create(recursive: true);
  await file.writeAsString(dartCode);
}
