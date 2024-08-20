// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TesteStruct extends BaseStruct {
  TesteStruct({
    String? teste,
  }) : _teste = teste;

  // "teste" field.
  String? _teste;
  String get teste => _teste ?? '';
  set teste(String? val) => _teste = val;

  bool hasTeste() => _teste != null;

  static TesteStruct fromMap(Map<String, dynamic> data) => TesteStruct(
        teste: data['teste'] as String?,
      );

  static TesteStruct? maybeFromMap(dynamic data) =>
      data is Map ? TesteStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'teste': _teste,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'teste': serializeParam(
          _teste,
          ParamType.String,
        ),
      }.withoutNulls;

  static TesteStruct fromSerializableMap(Map<String, dynamic> data) =>
      TesteStruct(
        teste: deserializeParam(
          data['teste'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'TesteStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is TesteStruct && teste == other.teste;
  }

  @override
  int get hashCode => const ListEquality().hash([teste]);
}

TesteStruct createTesteStruct({
  String? teste,
}) =>
    TesteStruct(
      teste: teste,
    );
