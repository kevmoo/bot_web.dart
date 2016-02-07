library tool.tasks.update_example_html;

import 'dart:async';
import 'dart:io';
import 'package:bot/bot.dart';
import 'package:hop/hop.dart';
import 'package:html5lib/dom.dart';
import 'package:html5lib/parser.dart';

const _startPath = r'example';
const _demoFinder = r'/**/*_demo.html';
final _exampleFile = _startPath + '/index.html';

Task getUpdateExampleHtmlTask() {
  return new Task((ctx) {
    return _getExampleFiles().then((List<String> demos) {
      ctx.info(demos.join('\n'));

      return _transform(demos);
    }).then((bool updated) {
      final String msg =
          updated ? '$_exampleFile updated!' : 'No changes to $_exampleFile';
      ctx.info(msg);
    });
  }, description: 'Updated the sample file at $_exampleFile');
}

Future<bool> transformHtml(
    String filePath, Future<Document> transformer(Document doc)) {
  return transformFile(filePath, (String content) {
    var parser = new HtmlParser(content, generateSpans: true);
    var document = parser.parse();

    return transformer(document).then((Document newDoc) {
      return newDoc.outerHtml;
    });
  });
}

/**
 * Assumes the target file, if it exists, is a [String].
 */
Future<bool> transformFile(
    String filePath, Future<String> transformer(String input),
    {bool ensureDirectory: false}) {
  String oldContent;
  String newContent;

  final file = new File(filePath);
  return FileSystemEntity.type(filePath).then((FileSystemEntityType fseType) {
    if (fseType == FileSystemEntityType.FILE) {
      return file.readAsString();
    } else if (fseType == FileSystemEntityType.NOT_FOUND) {
      return null;
    } else {
      throw new UnsupportedError('Cannot overwrite existing entity of'
          ' type $fseType');
    }
  }).then((String value) {
    oldContent = value;
    return transformer(oldContent);
  }).then((String value) {
    newContent = value;
    if (ensureDirectory) {
      return file.parent.create(recursive: true);
    }
  }).then((_) {
    // we're assuming file hasn't changed since we started
    if (newContent == oldContent) {
      // nothing changed
      return false;
    } else {
      return file
          .writeAsString(newContent, mode: FileMode.WRITE)
          .then((_) => true);
    }
  });
}

Future<bool> _transform(List<String> samples) {
  return transformHtml(_exampleFile, (Document doc) {
    _tweakDocument(doc, samples);
    return new Future<Document>.value(doc);
  });
}

void _tweakDocument(Document doc, List<String> samples) {
  final sampleList = doc
      .querySelectorAll('ul')
      .where((Element e) => e.id == 'demo-list')
      .single;

  sampleList.children.clear();

  for (final example in samples) {
    final anchor = new Element.tag('a')
      ..attributes['href'] = '$example/${example}_demo.html'
      ..attributes['target'] = 'demo'
      ..innerHtml = example;

    final li = new Element.tag('li')..children.add(anchor);
    sampleList.children.add(li);
  }
}

Future<List<String>> _getExampleFiles() {
  final findStr = _startPath + _demoFinder;
  return Process.run('bash', ['-c', 'find $findStr']).then((ProcessResult pr) {
    return Util.splitLines(pr.stdout.trim()).map((path) {
      assert(path.startsWith(_startPath));
      final lastSlash = path.lastIndexOf('/');
      final name = path.substring(_startPath.length + 1, lastSlash);
      // this could be a lot prettier...but...eh
      final targetPath = "$_startPath/$name/${name}_demo.html";
      assert(path == targetPath);
      return name;
    }).toList();
  });
}
