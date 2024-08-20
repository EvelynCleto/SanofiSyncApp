import '../database.dart';

class AcessoGeralTable extends SupabaseTable<AcessoGeralRow> {
  @override
  String get tableName => 'Acesso Geral';

  @override
  AcessoGeralRow createRow(Map<String, dynamic> data) => AcessoGeralRow(data);
}

class AcessoGeralRow extends SupabaseDataRow {
  AcessoGeralRow(super.data);

  @override
  SupabaseTable get table => AcessoGeralTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get idUsuario => getField<String>('id_usuario');
  set idUsuario(String? value) => setField<String>('id_usuario', value);

  String? get senha => getField<String>('senha');
  set senha(String? value) => setField<String>('senha', value);
}
