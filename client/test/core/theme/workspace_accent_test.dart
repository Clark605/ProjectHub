import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/theme/workspace_accent.dart';

void main() {
  group('WorkspaceAccent', () {
    test('contains 10 curated accent colors', () {
      expect(WorkspaceAccent.values.length, 10);
      final ids = WorkspaceAccent.values.map((a) => a.id).toSet();
      expect(ids, {
        'teal',
        'blue',
        'indigo',
        'violet',
        'pink',
        'rose',
        'orange',
        'amber',
        'lime',
        'cyan',
      });
    });

    test('resolves dark and light colors correctly for all accents', () {
      for (final accent in WorkspaceAccent.values) {
        expect(accent.resolvedColor(Brightness.dark), accent.darkColor);
        expect(accent.resolvedColor(Brightness.light), accent.lightColor);
        expect(accent.resolvedOnAccent(Brightness.dark), accent.onDark);
        expect(accent.resolvedOnAccent(Brightness.light), accent.onLight);
      }
    });

    test('fromId returns matching accent case-insensitively', () {
      expect(WorkspaceAccent.fromId('teal').id, 'teal');
      expect(WorkspaceAccent.fromId('TEAL').id, 'teal');
      expect(WorkspaceAccent.fromId('  Violet  ').id, 'violet');
      expect(WorkspaceAccent.fromId('orange').id, 'orange');
    });

    test('fromId falls back to teal for null, empty, or unknown id', () {
      expect(WorkspaceAccent.fromId(null).id, 'teal');
      expect(WorkspaceAccent.fromId('').id, 'teal');
      expect(WorkspaceAccent.fromId('   ').id, 'teal');
      expect(WorkspaceAccent.fromId('non_existent').id, 'teal');
    });
  });
}
