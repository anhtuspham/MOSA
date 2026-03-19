import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosa/utils/calculator_logic.dart';

/// Bottom sheet chứa bàn phím calculator (StatefulWidget để cập nhật display)
class CalculatorSheet extends StatefulWidget {
  final CalculatorLogic calculator;
  final Color amountColor;
  final ValueChanged<String> onDigitPressed;
  final ValueChanged<String> onOperatorPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback onTemplateNote;
  final VoidCallback onUpdate;

  const CalculatorSheet({
    super.key,
    required this.calculator,
    required this.amountColor,
    required this.onDigitPressed,
    required this.onOperatorPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
    required this.onTemplateNote,
    required this.onUpdate,
  });

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  void _rebuild() {
    setState(() {});
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Thanh kéo ───
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ─── Phần hiển thị số tiền bên trong sheet ───
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Flexible(
            //         child: Text(
            //           widget.calculator.isEmpty ? '0' : widget.calculator.displayText,
            //           textAlign: TextAlign.center,
            //           maxLines: 2,
            //           overflow: TextOverflow.ellipsis,
            //           style: TextStyle(
            //             fontSize: widget.calculator.hasOperator ? 24 : 32,
            //             fontWeight: FontWeight.bold,
            //             color: widget.amountColor,
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 4),
            //       Text(
            //         'đ',
            //         style: TextStyle(
            //           fontSize: widget.calculator.hasOperator ? 22 : 28,
            //           fontWeight: FontWeight.bold,
            //           color: widget.amountColor,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const Divider(height: 1),

            // ─── Bàn phím ───
            CalculatorKeyboardWithDone(
              onDigitPressed: (d) {
                widget.onDigitPressed(d);
                _rebuild();
              },
              onOperatorPressed: (op) {
                widget.onOperatorPressed(op);
                _rebuild();
              },
              onBackspace: () {
                widget.onBackspace();
                _rebuild();
              },
              onClear: () {
                widget.onClear();
                _rebuild();
              },
              onDone: widget.onDone,
              onTemplateNote: widget.onTemplateNote,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị số tiền trong ô nhập (ngoài bottom sheet)
class AmountDisplay extends StatelessWidget {
  final CalculatorLogic calculator;
  final Color amountColor;

  const AmountDisplay({super.key, required this.calculator, required this.amountColor});

  @override
  Widget build(BuildContext context) {
    final displayText = calculator.displayText;
    final isEmpty = calculator.isEmpty;
    final hasOperator = calculator.hasOperator;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            isEmpty ? '0' : displayText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: amountColor),
          ),
        ),
        const SizedBox(width: 4),
        Text('đ', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: amountColor)),
      ],
    );
  }
}

/// Widget hiển thị lưới bàn phím với nút Xong mở rộng 2 hàng
class CalculatorKeyboardWithDone extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final ValueChanged<String> onOperatorPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback onTemplateNote;

  const CalculatorKeyboardWithDone({
    super.key,
    required this.onDigitPressed,
    required this.onOperatorPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
    required this.onTemplateNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final numBg = colorScheme.surface;
    final opBg = colorScheme.surfaceContainerHighest;
    final clearBg = colorScheme.errorContainer.withValues(alpha: 0.6);
    const doneBg = Color(0xFF008fd3);

    final numStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colorScheme.onSurface);
    final opStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colorScheme.primary);

    const rowHeight = 52.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Ghi chép mẫu ───
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: _TemplateNoteButton(onTap: onTemplateNote),
          ),
        ),

        // ─── Hàng 1: AC  ÷  ×  ⌫ ───
        _buildRow([
          _KeyButton(
            height: rowHeight,
            bgColor: clearBg,
            onLongPress: onClear,
            onTap: () {
              HapticFeedback.lightImpact();
              onClear();
            },
            child: Text('AC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.error)),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: opBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onOperatorPressed('/');
            },
            child: Text('÷', style: opStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: opBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onOperatorPressed('*');
            },
            child: Text('×', style: opStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: opBg,
            onLongPress: () {
              HapticFeedback.mediumImpact();
              onClear();
            },
            onTap: () {
              HapticFeedback.lightImpact();
              onBackspace();
            },
            child: Icon(Icons.backspace_outlined, color: colorScheme.onSurface, size: 22),
          ),
        ]),

        // ─── Hàng 2: 7  8  9  - ───
        _buildRow([
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('7');
            },
            child: Text('7', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('8');
            },
            child: Text('8', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('9');
            },
            child: Text('9', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: opBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onOperatorPressed('-');
            },
            child: Text('-', style: opStyle),
          ),
        ]),

        // ─── Hàng 3: 4  5  6  + ───
        _buildRow([
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('4');
            },
            child: Text('4', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('5');
            },
            child: Text('5', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: numBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onDigitPressed('6');
            },
            child: Text('6', style: numStyle),
          ),
          _KeyButton(
            height: rowHeight,
            bgColor: opBg,
            onTap: () {
              HapticFeedback.lightImpact();
              onOperatorPressed('+');
            },
            child: Text('+', style: opStyle),
          ),
        ]),

        // ─── Hàng 4+5 (với nút Xong span 2 hàng) ───
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cột trái: 1,2,3 / 0,000,,
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDigitPressed('1');
                            },
                            child: Text('1', style: numStyle),
                          ),
                        ),
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDigitPressed('2');
                            },
                            child: Text('2', style: numStyle),
                          ),
                        ),
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDigitPressed('3');
                            },
                            child: Text('3', style: numStyle),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDigitPressed('0');
                            },
                            child: Text('0', style: numStyle),
                          ),
                        ),
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onDigitPressed('000');
                            },
                            child: Text('000', style: numStyle.copyWith(fontSize: 16)),
                          ),
                        ),
                        Expanded(
                          child: _KeyButton(
                            height: rowHeight,
                            bgColor: numBg,
                            onTap: null,
                            child: Text(',', style: numStyle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Cột phải: nút Xong (full height 2 hàng)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onDone();
                  },
                  child: Container(
                    color: doneBg,
                    alignment: Alignment.center,
                    child: const Text(
                      'Xong',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(children: children.map((w) => Expanded(child: w)).toList());
  }
}

/// Nút đơn của bàn phím
class _KeyButton extends StatelessWidget {
  final Widget child;
  final Color bgColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double height;

  const _KeyButton({required this.child, required this.bgColor, this.onTap, this.onLongPress, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15), width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Nút chip "Ghi chép mẫu" ở trên bàn phím
class _TemplateNoteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TemplateNoteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Ghi chép mẫu',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
