import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:arcanos_mayores/models/family_member.dart';
import 'package:arcanos_mayores/services/update_service.dart';

void main() {
  group('FamilyMember con arcano', () {
    test('arcanoNumero sobrevive el round trip a mapa', () {
      final m = FamilyMember(
        id: 3,
        nombre: 'Abuela',
        relacion: 'Abuela',
        arcanoNumero: 13,
        eventos: const ['Migracion'],
        fechaNacimiento: '1940-05-05',
      );

      final copia = FamilyMember.fromMap(m.toMap());

      expect(copia.arcanoNumero, 13);
      expect(copia.nombre, 'Abuela');
      expect(copia.eventos, ['Migracion']);
    });

    test('sin arcano queda null, sin lanzar', () {
      final m = FamilyMember(nombre: 'X', relacion: 'Otro');
      expect(m.toMap()['arcano_numero'], isNull);
      expect(FamilyMember.fromMap(m.toMap()).arcanoNumero, isNull);
    });
  });

  group('UpdateService.motivoApkInvalido', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('apk_check');
    });

    tearDown(() async {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    test('rechaza archivo inexistente', () async {
      final motivo = await UpdateService.motivoApkInvalido(
        File('${tmp.path}/no-existe.apk'),
        null,
      );
      expect(motivo, isNotNull);
    });

    test('rechaza un archivo demasiado chico', () async {
      final f = File('${tmp.path}/chico.apk');
      await f.writeAsBytes([0x50, 0x4B, 0x03, 0x04, 0, 0]);
      final motivo = await UpdateService.motivoApkInvalido(f, null);
      expect(motivo, contains('tamano'));
    });

    test('rechaza 10 MB que no son zip', () async {
      final f = File('${tmp.path}/falso.apk');
      await f.writeAsBytes(List.filled(10 * 1024 * 1024, 0x41));
      final motivo = await UpdateService.motivoApkInvalido(f, null);
      expect(motivo, isNotNull);
      expect(motivo, contains('zip'));
    });

    test('acepta un zip grande sin hash publicado', () async {
      final f = File('${tmp.path}/ok.apk');
      final bytes = List<int>.filled(6 * 1024 * 1024, 0x00);
      bytes[0] = 0x50;
      bytes[1] = 0x4B;
      bytes[2] = 0x03;
      bytes[3] = 0x04;
      await f.writeAsBytes(bytes);
      final motivo = await UpdateService.motivoApkInvalido(f, null);
      expect(motivo, isNull);
    });
  });
}
