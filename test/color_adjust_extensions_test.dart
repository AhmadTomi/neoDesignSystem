import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_design_system/neo_design_system.dart';

const _blue = Color(0xFF1D65AB);
const _gray = Color(0xFF808080);

double _hue(Color c) => OklchColor.fromColor(c).h;

void main() {
  group('ColorAdjustX lightness', () {
    test('lighten and darken move OKLCH lightness by the amount', () {
      final base = _blue.lightness;
      expect(_blue.lighten(0.1).lightness, closeTo(base + 0.1, 0.01));
      expect(_blue.darken(0.1).lightness, closeTo(base - 0.1, 0.01));
    });

    test('lightness changes keep the hue', () {
      expect(_hue(_blue.lighten(0.15)), closeTo(_hue(_blue), 2));
      expect(_hue(_blue.darken(0.15)), closeTo(_hue(_blue), 2));
    });

    test('withLightness sets an absolute value and clamps to 0..1', () {
      expect(_blue.withLightness(0.7).lightness, closeTo(0.7, 0.01));
      expect(_blue.withLightness(2), const Color(0xFFFFFFFF));
      expect(_blue.withLightness(-1), const Color(0xFF000000));
    });

    test('lighten past white and darken past black clamp', () {
      expect(_blue.lighten(5), const Color(0xFFFFFFFF));
      expect(_blue.darken(5), const Color(0xFF000000));
    });
  });

  group('ColorAdjustX saturation', () {
    test('saturate and desaturate scale chroma relatively', () {
      final base = _blue.chroma;
      expect(_blue.desaturate(0.5).chroma, closeTo(base * 0.5, 0.005));
      expect(_blue.saturate(0.2).chroma, greaterThan(base));
    });

    test('saturation changes keep lightness and hue', () {
      for (final c in [_blue.saturate(0.3), _blue.desaturate(0.3)]) {
        expect(c.lightness, closeTo(_blue.lightness, 0.01));
        expect(_hue(c), closeTo(_hue(_blue), 2));
      }
    });

    test('desaturate(1) and grayscale give a neutral gray of equal lightness', () {
      for (final c in [_blue.desaturate(1), _blue.grayscale]) {
        expect(c.chroma, lessThan(0.002));
        expect(c.lightness, closeTo(_blue.lightness, 0.01));
        expect(c.r, closeTo(c.g, 0.01));
        expect(c.g, closeTo(c.b, 0.01));
      }
    });

    test('saturating far beyond sRGB is gamut-mapped, not clipped', () {
      final vivid = _blue.saturate(10);
      expect(OklchColor.fromColor(vivid).isInGamut, isTrue);
      // Clipping channels would shift the hue; chroma reduction keeps it.
      expect(_hue(vivid), closeTo(_hue(_blue), 3));
      expect(vivid.lightness, closeTo(_blue.lightness, 0.02));
    });

    test('withChroma sets an absolute chroma; negative means gray', () {
      expect(_blue.withChroma(0.05).chroma, closeTo(0.05, 0.005));
      expect(_blue.withChroma(-1).chroma, lessThan(0.002));
    });
  });

  group('ColorAdjustX general', () {
    test('keeps alpha', () {
      final translucent = _blue.withValues(alpha: 0.4);
      expect(translucent.lighten(0.1).a, closeTo(0.4, 0.01));
      expect(translucent.desaturate(0.5).a, closeTo(0.4, 0.01));
    });

    test('a gray stays neutral when its lightness changes', () {
      final lighter = _gray.lighten(0.1);
      expect(lighter.chroma, lessThan(0.002));
      expect(lighter.lightness, closeTo(_gray.lightness + 0.1, 0.01));
    });

    test('zero amounts return the same color', () {
      expect(_blue.lighten(0), _blue);
      expect(_blue.saturate(0), _blue);
    });
  });

  group('OklchColor gamut helpers', () {
    test('toGamut lowers chroma only for out-of-gamut colors', () {
      const inside = OklchColor(0.6, 0.05, 250);
      expect(inside.isInGamut, isTrue);
      expect(identical(inside.toGamut(), inside), isTrue);

      const outside = OklchColor(0.6, 0.5, 250);
      expect(outside.isInGamut, isFalse);
      final mapped = outside.toGamut();
      expect(mapped.isInGamut, isTrue);
      expect(mapped.c, lessThan(outside.c));
      expect(mapped.l, outside.l);
      expect(mapped.h, outside.h);
    });
  });
}
