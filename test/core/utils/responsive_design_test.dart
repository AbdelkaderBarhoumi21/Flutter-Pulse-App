import 'package:flutter/painting.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/utils/responsive_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phones use the phone canvas, flipped in landscape', () {
    expect(
      ResponsiveDesign.designSizeFor(const Size(360, 740)),
      AppLayout.phoneDesignSize,
    );
    expect(
      ResponsiveDesign.designSizeFor(const Size(740, 360)),
      AppLayout.phoneDesignSize.flipped,
    );
  });

  test('tablets use the larger canvas, flipped in landscape', () {
    expect(
      ResponsiveDesign.designSizeFor(const Size(820, 1180)),
      AppLayout.tabletDesignSize,
    );
    expect(
      ResponsiveDesign.designSizeFor(const Size(1180, 820)),
      AppLayout.tabletDesignSize.flipped,
    );
  });
}
