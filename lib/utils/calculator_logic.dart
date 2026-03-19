import 'dart:developer';

/// Class quản lý logic máy tính cho bàn phím nhập số tiền.
/// Lưu trạng thái biểu thức dưới dạng chuỗi raw (không có dấu phân cách nghìn),
/// và cung cấp displayText đã được định dạng để hiển thị cho người dùng.
class CalculatorLogic {
  /// Chuỗi biểu thức raw, ví dụ: "150000+50000"
  String _expression = '';

  /// Toán tử cuối cùng được nhập (để phát hiện nhập toán tử liên tiếp)
  static const _operators = {'+', '-', '*', '/'};

  /// Trả về biểu thức hiện tại dạng thô
  String get rawExpression => _expression;

  /// Kiểm tra biểu thức có rỗng không
  bool get isEmpty => _expression.isEmpty;

  /// Kiểm tra biểu thức có chứa toán tử chưa hoàn thành không
  bool get hasOperator => _expression.contains(RegExp(r'[+\-*/]'));

  /// Trả về chuỗi hiển thị có định dạng (+dấu phân cách nghìn).
  /// Ví dụ: "150000+50000" → "150.000 + 50.000"
  String get displayText {
    if (_expression.isEmpty) return '';
    return _formatExpression(_expression);
  }

  /// Lấy giá trị số của toán hạng cuối (dùng để hiển thị riêng phần kết quả)
  String get lastOperandText {
    final parts = _splitExpression(_expression);
    if (parts.isEmpty) return '';
    return _formatNumber(parts.last);
  }

  /// Thêm một chữ số hoặc chuỗi "000" vào biểu thức
  void appendDigit(String digit) {
    // Kiểm tra giới hạn độ dài để tránh số quá lớn
    if (_expression.length >= 30) return;

    // Không bắt đầu bằng "000"
    if (_expression.isEmpty && digit == '000') return;

    // Không cho phép nhiều số 0 đứng đầu (vd: "007")
    if (digit == '0' || digit == '000') {
      final lastPart = _getLastOperand();
      if (lastPart == '0') return; // Đã có số 0 đơn rồi
    }

    // Nếu toán hạng trước là "0" đơn thì thay thế
    if (_getLastOperand() == '0' && digit != '000') {
      _expression = _expression.substring(0, _expression.length - 1);
    }

    _expression += digit;
  }

  /// Thêm toán tử vào biểu thức
  void appendOperator(String op) {
    if (_expression.isEmpty) return;

    final lastChar = _expression[_expression.length - 1];

    // Thay thế toán tử cuối nếu nhập liên tiếp
    if (_operators.contains(lastChar)) {
      _expression = _expression.substring(0, _expression.length - 1) + op;
    } else {
      _expression += op;
    }
  }

  /// Xóa ký tự cuối cùng trong biểu thức (backspace)
  void backspace() {
    if (_expression.isEmpty) return;
    _expression = _expression.substring(0, _expression.length - 1);
  }

  /// Xóa toàn bộ biểu thức (AC - All Clear)
  void clear() {
    _expression = '';
  }

  /// Tính kết quả biểu thức, trả về double.
  /// Nếu không có toán tử, trả về giá trị số duy nhất.
  /// Trả về 0.0 nếu biểu thức rỗng hoặc lỗi.
  double evaluate() {
    if (_expression.isEmpty) return 0.0;

    // Xóa toán tử thừa ở cuối
    String expr = _expression;
    while (expr.isNotEmpty && _operators.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }

    if (expr.isEmpty) return 0.0;

    try {
      return _evaluateExpression(expr);
    } catch (e) {
      log('Lỗi tính toán biểu thức: $e', name: 'CalculatorLogic');
      return 0.0;
    }
  }

  /// Tính và cập nhật lại expression thành kết quả (sau khi bấm "Xong")
  /// Trả về kết quả dưới dạng double
  double evaluateAndReset() {
    final result = evaluate();
    if (result == 0.0 && _expression.isEmpty) {
      return 0.0;
    }
    // Lưu kết quả vào expression dưới dạng số nguyên (không có toán tử)
    _expression =
        result == result.floorToDouble()
            ? result.toInt().toString()
            : result.toStringAsFixed(0);
    return result;
  }

  // ──────────────── Private helpers ────────────────

  /// Lấy toán hạng cuối trong biểu thức
  String _getLastOperand() {
    final parts = _splitByOperators(_expression);
    return parts.isEmpty ? '' : parts.last;
  }

  /// Tách biểu thức thành danh sách các phần (số và toán tử xen kẽ)
  List<String> _splitByOperators(String expr) {
    if (expr.isEmpty) return [];
    // Phân tách giữ lại toán tử
    return expr.split(RegExp(r'(?=[+\-*/])|(?<=[+\-*/])'));
  }

  /// Tách biểu thức thành các toán hạng (bỏ toán tử)
  List<String> _splitExpression(String expr) {
    if (expr.isEmpty) return [];
    return expr.split(RegExp(r'[+\-*/]')).where((s) => s.isNotEmpty).toList();
  }

  /// Định dạng chuỗi số với dấu phân cách nghìn bằng dấu chấm
  String _formatNumber(String numStr) {
    if (numStr.isEmpty) return '';
    final val = int.tryParse(numStr);
    if (val == null) return numStr;

    final str = val.toString();
    final buffer = StringBuffer();
    final start = str.length % 3;

    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (i - start) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// Định dạng toàn bộ biểu thức để hiển thị
  String _formatExpression(String expr) {
    if (expr.isEmpty) return '';

    final buffer = StringBuffer();
    String current = '';

    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (_operators.contains(ch)) {
        if (current.isNotEmpty) {
          buffer.write(_formatNumber(current));
          current = '';
        }
        buffer.write(' $ch ');
      } else {
        current += ch;
      }
    }

    if (current.isNotEmpty) {
      buffer.write(_formatNumber(current));
    }

    return buffer.toString();
  }

  /// Tính toán biểu thức theo thứ tự ưu tiên toán tử cơ bản
  double _evaluateExpression(String expr) {
    // Bước 1: Tách theo + và - (từ phải sang trái để xử lý ưu tiên)
    // Bước 2: Với mỗi phần, tách theo * và /
    // Đây là cách đơn giản không dùng parser phức tạp

    // Tách biểu thức thành tokens (số và toán tử)
    final tokens = <String>[];
    String current = '';

    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (_operators.contains(ch)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(ch);
      } else {
        current += ch;
      }
    }
    if (current.isNotEmpty) tokens.add(current);

    // Xử lý * và / trước
    final reduced = <String>[];
    int i = 0;
    while (i < tokens.length) {
      if ((tokens[i] == '*' || tokens[i] == '/') && reduced.isNotEmpty) {
        final left = double.parse(reduced.removeLast());
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        reduced.add(result.toString());
        i += 2;
      } else {
        reduced.add(tokens[i]);
        i++;
      }
    }

    // Xử lý + và -
    double result = double.parse(reduced[0]);
    int j = 1;
    while (j < reduced.length) {
      final op = reduced[j];
      final val = double.parse(reduced[j + 1]);
      if (op == '+') {
        result += val;
      } else if (op == '-') {
        result -= val;
      }
      j += 2;
    }

    return result;
  }
}
