import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // EdgeInsets helpers
  static const EdgeInsets paddingAllXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // SizedBox helpers
  static const SizedBox gapHxxs = SizedBox(height: xxs);
  static const SizedBox gapHxs = SizedBox(height: xs);
  static const SizedBox gapHsm = SizedBox(height: sm);
  static const SizedBox gapHmd = SizedBox(height: md);
  static const SizedBox gapHlg = SizedBox(height: lg);
  static const SizedBox gapHxl = SizedBox(height: xl);
  static const SizedBox gapHxxl = SizedBox(height: xxl);

  static const SizedBox gapWxxs = SizedBox(width: xxs);
  static const SizedBox gapWxs = SizedBox(width: xs);
  static const SizedBox gapWsm = SizedBox(width: sm);
  static const SizedBox gapWmd = SizedBox(width: md);
  static const SizedBox gapWlg = SizedBox(width: lg);
  static const SizedBox gapWxl = SizedBox(width: xl);
}
