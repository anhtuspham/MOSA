import 'dart:developer';

import 'package:mosa/models/budget.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/models/wallets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service đồng bộ dữ liệu giữa SQLite local và Supabase cloud.
///
/// Chiến lược: Offline-first — SQLite là nguồn chính, Supabase là cloud backup.
/// - Mỗi thao tác CRUD trên SQLite sẽ gọi sync background lên Supabase.
/// - `syncId` (UUID) là khóa idempotency để tránh duplicate khi upsert.
/// - `user_id` = `auth.uid()` được thêm tự động, RLS bảo vệ data giữa các user.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Lấy user ID hiện tại, null nếu chưa đăng nhập
  String? get _userId => _client.auth.currentUser?.id;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isLoggedIn => _userId != null;

  // ==================== WALLETS ====================

  /// Đồng bộ một ví lên Supabase (upsert theo sync_id)
  Future<void> syncWallet(Wallet wallet) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('wallets').upsert({
        'user_id': _userId,
        'local_id': wallet.id,
        'sync_id': wallet.syncId,
        'name': wallet.name,
        'icon_path': wallet.iconPath,
        'initial_balance': wallet.initialBalance,
        'balance': wallet.balance,
        'type_wallet_id': wallet.typeWalletId,
        'is_default': wallet.isDefault,
        'is_active': wallet.isActive,
        'note': wallet.note,
        'bank_id': wallet.bankId,
        'created_at': wallet.createAt.toIso8601String(),
        'updated_at': wallet.updateAt?.toIso8601String(),
      }, onConflict: 'sync_id');
      log('✅ Sync wallet thành công: ${wallet.name}', name: 'SupabaseService');
    } catch (e) {
      log('❌ Sync wallet thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa ví trên Supabase theo syncId
  Future<void> deleteWallet(String syncId) async {
    if (!isLoggedIn) return;
    try {
      await _client
          .from('wallets')
          .delete()
          .eq('sync_id', syncId)
          .eq('user_id', _userId!);
      log('✅ Xóa wallet trên Supabase: $syncId', name: 'SupabaseService');
    } catch (e) {
      log('❌ Xóa wallet thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy tất cả ví của user từ Supabase
  Future<List<Map<String, dynamic>>> fetchWallets() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client.from('wallets').select().order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch wallets thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== TRANSACTIONS ====================

  /// Đồng bộ một giao dịch lên Supabase.
  ///
  /// Lưu ý: [walletSupabaseId] là UUID của ví trên Supabase (cần tra từ sync_id).
  /// Nếu chưa có mapping, truyền null để bỏ qua liên kết wallet (sẽ sync lại sau).
  Future<void> syncTransaction(
    TransactionModel transaction, {
    String? walletSupabaseId,
    String? categorySupabaseId,
  }) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('transactions').upsert({
        'user_id': _userId,
        'local_id': transaction.id,
        'sync_id': transaction.syncId,
        'title': transaction.title,
        'amount': transaction.amount,
        'category_id': categorySupabaseId ?? transaction.categoryId,
        'wallet_id': walletSupabaseId,
        'date': transaction.date.toIso8601String(),
        'type': transaction.type.name,
        'note': transaction.note,
        'due_date': transaction.dueDate?.toIso8601String(),
        'created_at': transaction.createAt.toIso8601String(),
        'updated_at': transaction.updateAt?.toIso8601String(),
      }, onConflict: 'sync_id');
      log(
        '✅ Sync transaction thành công: ${transaction.title}',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Sync transaction thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa giao dịch trên Supabase theo syncId
  Future<void> deleteTransaction(String syncId) async {
    if (!isLoggedIn) return;
    try {
      await _client
          .from('transactions')
          .delete()
          .eq('sync_id', syncId)
          .eq('user_id', _userId!);
      log('✅ Xóa transaction trên Supabase: $syncId', name: 'SupabaseService');
    } catch (e) {
      log('❌ Xóa transaction thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy danh sách giao dịch từ Supabase
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client
          .from('transactions')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch transactions thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== PERSONS ====================

  /// Đồng bộ một người lên Supabase
  Future<void> syncPerson(Person person) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('persons').upsert(
        {
          'user_id': _userId,
          'local_id': person.id,
          'name': person.name,
          'icon_path': person.iconPath,
          'created_at':
              person.createAt?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          'updated_at': person.updateAt?.toIso8601String(),
        },
        // Unique per (user_id, name) — dùng để upsert đúng bản ghi
        onConflict: 'user_id,name',
      );
      log('✅ Sync person thành công: ${person.name}', name: 'SupabaseService');
    } catch (e) {
      log('❌ Sync person thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa người trên Supabase theo local_id
  Future<void> deletePerson(int localId) async {
    if (!isLoggedIn) return;
    try {
      await _client
          .from('persons')
          .delete()
          .eq('local_id', localId)
          .eq('user_id', _userId!);
      log(
        '✅ Xóa person trên Supabase: localId=$localId',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Xóa person thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy danh sách người từ Supabase
  Future<List<Map<String, dynamic>>> fetchPersons() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client.from('persons').select().order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch persons thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== DEBTS ====================

  /// Đồng bộ một khoản nợ lên Supabase.
  ///
  /// [personSupabaseId] và [walletSupabaseId] là các UUID Supabase tương ứng.
  Future<void> syncDebt(
    Debt debt, {
    String? personSupabaseId,
    String? walletSupabaseId,
  }) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('debts').upsert({
        'user_id': _userId,
        'local_id': debt.id,
        'person_id': personSupabaseId,
        'wallet_id': walletSupabaseId,
        'amount': debt.amount,
        'paid_amount': debt.paidAmount,
        'type': debt.type.name,
        'status': debt.status.name,
        'description': debt.description,
        'created_date': debt.createdDate.toIso8601String(),
        'due_date': debt.dueDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,local_id');
      log(
        '✅ Sync debt thành công: localId=${debt.id}',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Sync debt thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa khoản nợ trên Supabase theo local_id
  Future<void> deleteDebt(int localId) async {
    if (!isLoggedIn) return;
    try {
      await _client
          .from('debts')
          .delete()
          .eq('local_id', localId)
          .eq('user_id', _userId!);
      log(
        '✅ Xóa debt trên Supabase: localId=$localId',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Xóa debt thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy danh sách khoản nợ từ Supabase
  Future<List<Map<String, dynamic>>> fetchDebts() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client
          .from('debts')
          .select()
          .order('created_date', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch debts thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== CATEGORIES ====================

  /// Đồng bộ một category do user tạo lên Supabase.
  ///
  /// Chỉ sync các category của user (is_global = false).
  /// Global categories do admin seed trực tiếp trên Supabase, không sync từ app.
  Future<void> syncUserCategory(Category category) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('categories').upsert({
        'id': category.id,
        'user_id': _userId,
        'name': category.name,
        'type': category.type,
        'icon_type': category.iconType,
        'icon_path': category.iconPath,
        'color': category.color,
        'parent_id': category.parentId,
        'is_global': false,
      }, onConflict: 'id');
      log(
        '✅ Sync category thành công: ${category.name}',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Sync category thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa category user trên Supabase theo id
  Future<void> deleteUserCategory(String categoryId) async {
    if (!isLoggedIn) return;
    try {
      // Chỉ xóa được category của chính mình, RLS ngăn xóa global
      await _client.from('categories').delete().eq('id', categoryId);
      log('✅ Xóa category trên Supabase: $categoryId', name: 'SupabaseService');
    } catch (e) {
      log('❌ Xóa category thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy tất cả categories (global + của user) từ Supabase.
  ///
  /// RLS policy đã tự động lọc: global categories + categories của user hiện tại.
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client.from('categories').select().order('name');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch categories thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== BUDGETS ====================

  /// Đồng bộ một budget lên Supabase
  Future<void> syncBudget(Budget budget) async {
    if (!isLoggedIn) return;
    try {
      await _client.from('budgets').upsert({
        'user_id': _userId,
        'local_id': budget.id,
        'category_id': budget.categoryId,
        'amount': budget.amount,
        'month': budget.month,
        'year': budget.year,
      }, onConflict: 'user_id,local_id');
      log(
        '✅ Sync budget thành công: ${budget.categoryId}/${budget.month}/${budget.year}',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Sync budget thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Xóa budget trên Supabase theo local_id
  Future<void> deleteBudget(int localId) async {
    if (!isLoggedIn) return;
    try {
      await _client
          .from('budgets')
          .delete()
          .eq('local_id', localId)
          .eq('user_id', _userId!);
      log(
        '✅ Xóa budget trên Supabase: localId=$localId',
        name: 'SupabaseService',
      );
    } catch (e) {
      log('❌ Xóa budget thất bại: $e', name: 'SupabaseService');
    }
  }

  /// Lấy danh sách budgets từ Supabase
  Future<List<Map<String, dynamic>>> fetchBudgets() async {
    if (!isLoggedIn) return [];
    try {
      final data = await _client.from('budgets').select();
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('❌ Fetch budgets thất bại: $e', name: 'SupabaseService');
      return [];
    }
  }

  // ==================== FULL SYNC ====================

  /// Push toàn bộ data local lên Supabase (dùng khi user mới đăng nhập lần đầu).
  ///
  /// Truyền vào danh sách data từ SQLite, gọi tuần tự để tránh rate limit.
  /// Thứ tự quan trọng: wallets → persons → categories → transactions → debts → budgets
  Future<void> pushAllToCloud({
    required List<Wallet> wallets,
    required List<Person> persons,
    required List<Category> userCategories,
    required List<TransactionModel> transactions,
    required List<Debt> debts,
    required List<Budget> budgets,
  }) async {
    if (!isLoggedIn) return;

    log(
      '🚀 Bắt đầu push toàn bộ data lên Supabase...',
      name: 'SupabaseService',
    );

    // 1. Sync wallets trước (transactions cần wallet_id)
    for (final wallet in wallets) {
      await syncWallet(wallet);
    }

    // 2. Sync persons (debts cần person_id)
    for (final person in persons) {
      await syncPerson(person);
    }

    // 3. Sync user categories (transactions cần category_id)
    for (final category in userCategories) {
      await syncUserCategory(category);
    }

    // 4. Sync transactions (không cần resolve wallet UUID vì dùng local_id tạm thời)
    for (final tx in transactions) {
      await syncTransaction(tx);
    }

    // 5. Sync debts
    for (final debt in debts) {
      await syncDebt(debt);
    }

    // 6. Sync budgets
    for (final budget in budgets) {
      await syncBudget(budget);
    }

    log('✅ Push toàn bộ data hoàn tất', name: 'SupabaseService');
  }
}
