import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'database_service_provider.dart';

class PersonNotifier extends AsyncNotifier<List<Person>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Person>> build() async {
    return await _databaseService.getAllPersons();
  }

  /// Add new person
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

  /// Update existing person
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

  /// Refresh person list from database
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

// Main provider - AsyncNotifier for full CRUD
final personProvider = AsyncNotifierProvider<PersonNotifier, List<Person>>(PersonNotifier.new);

// Selection provider - tracks currently selected person
final selectedPersonProvider = StateProvider<Person?>((ref) => null);

final personByIdProvider = Provider.family<Person?, int>((ref, personId) {
  final persons = ref.watch(personProvider).value ?? [];
  return CollectionUtils.safeLookup(persons, (person) => person.id == personId);
});
