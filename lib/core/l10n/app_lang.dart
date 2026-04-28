import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';

extension AppLangContext on BuildContext {
  String tr(String vi, String en) {
    final lang = Provider.of<LanguageProvider>(this, listen: false);
    return lang.isVietnamese ? vi : en;
  }
}
