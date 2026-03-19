import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/calculator_logic.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/utils/utils.dart';
import 'package:mosa/widgets/calculator_keyboard.dart';
import 'package:mosa/widgets/card_section.dart';

/// Widget nhập số tiền với bàn phím máy tính tùy chỉnh.
/// Bàn phím chỉ hiển thị khi người dùng tap vào ô nhập số,
/// trượt lên từ dưới màn hình như system keyboard.
class AmountInputSection extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final TransactionType? transactionType;

  const AmountInputSection({super.key, required this.controller, this.transactionType});

  @override
  ConsumerState<AmountInputSection> createState() => _AmountInputSectionState();
}

class _AmountInputSectionState extends ConsumerState<AmountInputSection> {
  final CalculatorLogic _calculator = CalculatorLogic();

  /// Trạng thái bàn phím đang mở hay không
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    // Đọc giá trị ban đầu từ controller nếu có (trường hợp prefill)
    final initialText = widget.controller.text.replaceAll('.', '');
    if (initialText.isNotEmpty && initialText != '0') {
      final value = double.tryParse(initialText);
      if (value != null && value > 0) {
        _calculator.appendDigit(value.toInt().toString());
        _syncControllerFromCalculator();
      }
    }
  }

  @override
  void didUpdateWidget(AmountInputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Đồng bộ khi controller thay đổi từ ngoài (ví dụ: reset form)
    final raw = widget.controller.text.replaceAll('.', '');
    if (raw.isEmpty || raw == '0') {
      if (_calculator.rawExpression != '') {
        setState(() => _calculator.clear());
      }
    }
  }

  /// Ghi giá trị đã tính vào controller (dạng có dấu chấm phân cách nghìn)
  void _syncControllerFromCalculator() {
    final raw = _calculator.rawExpression;
    if (raw.isEmpty) {
      widget.controller.text = '';
      return;
    }
    widget.controller.text = _calculator.displayText;
  }

  /// Mở bàn phím dưới dạng bottom sheet
  void _openKeyboard() {
    if (_isKeyboardOpen) return;
    _isKeyboardOpen = true;

    showModalBottomSheet<void>(
      context: context,
      // Không dùng isDismissible để bắt buộc nhấn Xong
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return CalculatorSheet(
          calculator: _calculator,
          amountColor: getTransactionTypeColor(type: widget.transactionType ?? TransactionType.expense),
          onDigitPressed: _onDigitPressed,
          onOperatorPressed: _onOperatorPressed,
          onBackspace: _onBackspace,
          onClear: _onClear,
          onDone: () {
            _onDone();
            Navigator.of(sheetContext).pop();
          },
          onTemplateNote: _onTemplateNote,
          onUpdate: () => setState(() {}),
        );
      },
    ).whenComplete(() {
      _isKeyboardOpen = false;
      // Đảm bảo UI đồng bộ sau khi đóng bàn phím
      setState(() {});
    });
  }

  void _onDigitPressed(String digit) {
    _calculator.appendDigit(digit);
    _syncControllerFromCalculator();
  }

  void _onOperatorPressed(String op) {
    _calculator.appendOperator(op);
  }

  void _onBackspace() {
    _calculator.backspace();
    _syncControllerFromCalculator();
  }

  void _onClear() {
    _calculator.clear();
    widget.controller.text = '';
  }

  void _onDone() {
    final result = _calculator.evaluateAndReset();
    _syncControllerFromCalculator();
    if (result > 0) {
      final formatted = _formatResult(result);
      widget.controller.text = formatted;
    }
    setState(() {});
  }

  void _onTemplateNote() {
    // TODO: Triển khai tính năng ghi chép mẫu khi có data model
    showInfoToast('Tính năng ghi chép mẫu đang được phát triển.');
  }

  /// Định dạng kết quả thành chuỗi có dấu phân cách nghìn (dấu chấm)
  String _formatResult(double value) {
    final int intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    final start = str.length % 3;
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (i - start) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = getTransactionTypeColor(type: widget.transactionType ?? TransactionType.expense);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            TransactionConstants.amountLabel,
            style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          // ─── Ô nhập số - tap để mở bàn phím ───
          GestureDetector(
            onTap: _openKeyboard,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // border: Border.all(
                //   color:
                //       _isKeyboardOpen
                //           ? colorScheme.primary
                //           : colorScheme.outline.withValues(alpha: 0.3),
                //   width: _isKeyboardOpen ? 1.5 : 1,
                // ),
              ),
              child: AmountDisplay(calculator: _calculator, amountColor: amountColor),
            ),
          ),
        ],
      ),
    );
  }
}


