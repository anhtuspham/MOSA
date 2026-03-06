import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'database_service_provider.dart';

/// Quản lý trạng thái danh sách người cho vay/đi vay
class PersonNotifier extends AsyncNotifier<List<Person>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Person>> build() async {
    return await _databaseService.getAllPersons();
  }

  /// Thêm người mới
  Future<void> addPerson(Person person) async {
    state = const AsyncLoading();

    try {
      final id = await _databaseService.insertPerson(person);
      final newPerson = person.copyWith(id: id);

      // Update state immediately
      state = AsyncData([newPerson, ...state.requireValue]);

      // Refresh from database to ensure consistency
      await refreshPersons();
    } catch (e) {
      log('Error adding person: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Cập nhật thông tin người
  Future<void> updatePerson(Person person) async {
    state = const AsyncLoading();

    try {
      await _databaseService.updatePerson(person);

      // Find and update in state
      final index = state.requireValue.indexWhere((p) => p.id == person.id);
      if (index != -1) {
        final updatedList = [...state.requireValue];
        updatedList[index] = person;
        state = AsyncData(updatedList);
      }

      await refreshPersons();
    } catch (e) {
      log('Error updating person: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Làm mới danh sách người từ database
  Future<void> refreshPersons() async {
    try {
      final persons = await _databaseService.getAllPersons();
      if (persons != state.value) {
        state = AsyncData(persons);
      }
    } catch (e) {
      log('Error refreshing persons: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }
}

/// Provider chính quản lý danh sách người
final personProvider = AsyncNotifierProvider<PersonNotifier, List<Person>>(
  PersonNotifier.new,
);

/// Provider lưu trữ người được chọn hiện tại
final selectedPersonProvider = StateProvider<Person?>((ref) => null);

/// Lấy người theo ID
final personByIdProvider = Provider.family<Person?, int>((ref, personId) {
  final persons = ref.watch(personProvider).value ?? [];
  return CollectionUtils.safeLookup(persons, (person) => person.id == personId);
});
