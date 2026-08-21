import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:core_web3dart/src/builder/generator.dart';

Future<void> main() async {
  final data = <String, String>{};

  final dir = Directory('test/builder');
  await for (final file in dir.list()) {
    if (file is File && file.path.endsWith('.abi.json')) {
      // Generate golden data
      final content = await file.readAsString();
      final result = await testBuilder(const ContractGenerator(), {
        'a|lib/contract.abi.json': content,
      }, flattenOutput: true);

      final output = result.readerWriter.testing.readBytes(
        AssetId('a', 'lib/contract.g.dart'),
      );
      data[content] = utf8.decode(output);
    }
  }

  final output = File('test/builder/data.dart');
  final resultBuilder = StringBuffer();
  resultBuilder.writeln('const testCases = <String, String>{');
  data.forEach((key, value) {
    resultBuilder.writeln("r'''");
    resultBuilder.write(key);
    resultBuilder.writeln("''':");

    resultBuilder.writeln("r'''");
    resultBuilder.write(value);
    resultBuilder.writeln("''',");
  });
  resultBuilder.writeln('};');
  await output.writeAsString(resultBuilder.toString());
}
