library harness_console;

import 'package:unittest/unittest.dart';
import 'test_dump_render_tree.dart' as drt;

void main() {
  groupSep = ' - ';

  drt.main();
}
