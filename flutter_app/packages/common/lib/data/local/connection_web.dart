import 'package:drift/drift.dart';

class WebInMemoryExecutor extends QueryExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async {
    return true;
  }

  @override
  QueryExecutor beginExclusive() {
    return this;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    return const [];
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  TransactionExecutor beginTransaction() {
    return WebInMemoryTransaction();
  }
}

class WebInMemoryTransaction extends TransactionExecutor {
  @override
  SqlDialect get dialect => SqlDialect.sqlite;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) async {
    return true;
  }

  @override
  QueryExecutor beginExclusive() {
    return this;
  }

  @override
  TransactionExecutor beginTransaction() {
    return this;
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {}

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {}

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(String statement, List<Object?> args) async {
    return const [];
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    return 0;
  }

  Future<void> commit() async {}

  @override
  Future<void> rollback() async {}

  @override
  Future<void> send() async {}

  @override
  bool get supportsNestedTransactions => false;
}

QueryExecutor openConnection() {
  return WebInMemoryExecutor();
}
