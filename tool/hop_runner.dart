library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import 'package:hop_unittest/hop_unittest.dart';

import '../test/harness_console.dart' as test_console;

import 'tasks/update_example_html.dart' as html_tasks;

void main(List<String> args) {
  // Easy to enable hop-wide logging
  // enableScriptLogListener();

  addTask('test', createUnitTestTask(test_console.main));

  //
  // Analyzer
  //
  addTask('analyze_libs', createAnalyzerTask(_getLibs));

  addTask('analyze_test_libs', createAnalyzerTask(
      ['test/harness_browser.dart', 'test/harness_console.dart',
       'test/test_dump_render_tree.dart',]));

  //
  // Dart2js
  //
  final paths = ['click', 'drag', 'fract', 'frames', 'nav', 'spin']
      .map((d) => "example/bot_retained/$d/${d}_demo.dart")
      .toList();
  paths.add('test/harness_browser.dart');

  addTask('dart2js', createDartCompilerTask(paths, liveTypeAnalysis: true));

  addTask('update-html', html_tasks.getUpdateExampleHtmlTask());

  runHop(args);
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
