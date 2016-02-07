library harness_browser;

import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';
import 'bot_retained/_bot_retained.dart' as bot_retained;

main() {
  groupSep = ' - ';
  useHtmlEnhancedConfiguration();

  bot_retained.register();
}
