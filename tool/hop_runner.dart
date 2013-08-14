library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';
import '../test/harness_console.dart' as test_console;

import 'tasks/update_example_html.dart' as html_tasks;
import 'package:hop/src/hop_tasks_experimental.dart' as dartdoc;

void main() {
  // Easy to enable hop-wide logging
  // enableScriptLogListener();

  addTask('test', createUnitTestTask(test_console.testCore));

  addTask('docs', createDartDocTask(_getLibs, linkApi: true, postBuild: dartdoc.createPostBuild(_cfg)));

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

  runHop();
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}

const _libs = const ['bot_html', 'bot_retained', 'bot_texture'];

final _cfg = new dartdoc.DocsConfig('bot_web', 'https://github.com/kevmoo/bot_web.dart',
    'logo.png', 333, 250, _libs.contains);
