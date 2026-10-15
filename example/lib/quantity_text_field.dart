import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neo_design_system/neo_design_system.dart';

enum TextFormFieldType { all, price, bigPrice, volume, twoLen, threeLen }

class CurrencyTextInputFormatter extends TextInputFormatter {
  final NumberFormat numberFormat;
  const CurrencyTextInputFormatter(this.numberFormat);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final raw = newValue.text.replaceAll(',', '');
    if ((numberFormat.decimalDigits ?? 0) > 0) {
      final val = double.tryParse(raw);
      if (val == null) return oldValue;
      if (raw.endsWith('.')) {
        final intPart = int.tryParse(raw.substring(0, raw.length - 1)) ?? 0;
        final formattedInt = NumberFormat.currency(
          locale: 'en_US',
          decimalDigits: 0,
          symbol: '',
        ).format(intPart).trim();
        return TextEditingValue(
          text: '$formattedInt.',
          selection: TextSelection.collapsed(offset: formattedInt.length + 1),
        );
      }
      final parts = raw.split('.');
      final intPart = int.tryParse(parts[0]) ?? 0;
      final formattedInt = NumberFormat.currency(
        locale: 'en_US',
        decimalDigits: 0,
        symbol: '',
      ).format(intPart).trim();
      final decPart = parts.length > 1 ? '.${parts[1]}' : '';
      final formatted = '$formattedInt$decPart';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      final val = int.tryParse(raw);
      if (val == null) return oldValue;
      final formatted = numberFormat.format(val).trim();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

class QuantityTextField extends StatefulWidget {
  final bool enable;
  final num? initialValue;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final TextFormFieldType? textFieldType;
  final FocusNode? focusNode;
  final num Function(num value)? fraction;
  final int decimalDigits;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final bool autofocus;
  final BorderRadiusGeometry? radius;

  const QuantityTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.initialValue,
    this.enable = true,
    this.onTap,
    this.textFieldType,
    this.focusNode,
    this.onFieldSubmitted,
    this.fraction,
    this.decimalDigits = 0,
    this.textInputAction,
    this.textAlign = TextAlign.right,
    this.autofocus = false,
    this.radius,
  });

  @override
  State<QuantityTextField> createState() => _QuantityTextFieldState();
}

class _QuantityTextFieldState extends State<QuantityTextField> {
  late final TextEditingController _textController;
  late FocusNode _focusNode;
  late final bool _isInternalController;
  late final bool _isInternalFocusNode;

  late final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    decimalDigits: widget.decimalDigits,
    symbol: '',
  );
  num numberValue = 0;

  bool get _allowDecimal => widget.decimalDigits > 0;

  @override
  void initState() {
    super.initState();
    _isInternalController = widget.controller == null;
    _textController = widget.controller ?? TextEditingController();
    _isInternalFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();

    if (_textController.text.isEmpty && widget.initialValue != null) {
      _textController.text = _currencyFormat.format(widget.initialValue).trim();
    } else if (_textController.text.isNotEmpty) {
      _convertNum();
      _textController.text = _currencyFormat.format(numberValue).trim();
    }
    _convertNum();
    _textController.addListener(_convertNum);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      if (_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _selectAll();
        });
      } else {
        if (_textController.text.isEmpty) {
          _textController.text = _currencyFormat.format(numberValue).trim();
        }
      }
    });
  }

  void _selectAll() {
    if (_textController.text.isNotEmpty) {
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    }
  }

  @override
  void didUpdateWidget(covariant QuantityTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_convertNum);
    _focusNode.removeListener(_onFocusChanged);
    if (_isInternalController) {
      _textController.dispose();
    }
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final colorTheme = context.color;

    return Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && _focusNode.hasFocus) {
          if (HardwareKeyboard.instance.isAltPressed ||
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isShiftPressed) {
            return KeyEventResult.ignored;
          }

          if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.numpadAdd) {
            _incrementValue();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.numpadSubtract) {
            _decrementValue();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 30,
        decoration: BoxDecoration(
          color: isFocused
              ? colorTheme.primary.withValues(alpha: 0.04)
              : (widget.enable ? colorTheme.container2 : colorTheme.container3),
          borderRadius: widget.radius ?? BorderRadius.circular(6),
          border: Border.all(
            color: isFocused
                ? colorTheme.primary
                : context.color.dividerLine.withValues(alpha: 0.8),
            width: isFocused ? 1.0 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: _textController,
                textAlignVertical: TextAlignVertical.center,
                style: context.text.bodyMedium?.tabular?.copyWith(
                  fontSize: 13,
                  color: widget.enable ? null : context.color.textDisabled,
                  fontWeight: FontWeight.bold,
                ),
                enabled: widget.enable,
                textAlign: widget.textAlign,
                maxLength: _allowDecimal
                    ? maxLength + widget.decimalDigits + 1
                    : maxLength,
                autofocus: widget.autofocus,
                focusNode: _focusNode,
                textInputAction: widget.textInputAction ?? TextInputAction.next,
                onTap: () {
                  _selectAll();
                  widget.onTap?.call();
                },
                onChanged: (value) {
                  widget.onChanged?.call(_valueAsString(numberValue));
                },
                onFieldSubmitted: widget.onFieldSubmitted,
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
                decoration: const InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  hoverColor: Colors.transparent,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  counter: SizedBox.shrink(),
                  contentPadding: EdgeInsets.only(
                    right: 6,
                    left: 4,
                  ),
                  fillColor: Colors.transparent,
                ),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: _allowDecimal,
                ),
                inputFormatters: [
                  CurrencyTextInputFormatter(_currencyFormat),
                  FilteringTextInputFormatter.deny(RegExp(r'-')),
                  if (_allowDecimal)
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final dotCount = '.'.allMatches(newValue.text).length;
                      if (dotCount > 1) return oldValue;
                      return newValue;
                    })
                  else
                    FilteringTextInputFormatter.deny(RegExp(r'\.')),
                ],
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.remove,
                    onTap: _decrementValue,
                  ),
                  VerticalDivider(
                    color: context.color.dividerLine.withValues(alpha: 0.5),
                    width: 1,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.add,
                    onTap: _incrementValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: widget.enable ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: widget.enable
                  ? context.color.textMain
                  : context.color.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  void _decrementValue() {
    if (numberValue > 0) {
      final step = fraction(numberValue - 1);
      numberValue = _roundToDecimals(max(0, numberValue - step));
      _textController.text = _currencyFormat.format(numberValue).trim();
      widget.onChanged?.call(_valueAsString(numberValue));
      HapticFeedback.lightImpact();
    }
  }

  void _incrementValue() {
    final step = fraction(numberValue);
    final incremented = _roundToDecimals(numberValue + step);
    if (_exceedsMax(incremented)) {
      return;
    }
    numberValue = incremented;
    _textController.text = _currencyFormat.format(numberValue).trim();
    widget.onChanged?.call(_valueAsString(numberValue));
    HapticFeedback.lightImpact();
  }

  num fraction(num value) {
    if (widget.fraction != null) {
      return widget.fraction!(value);
    }
    return 1;
  }

  String _valueAsString(num value) {
    if (_allowDecimal) {
      return value
          .toStringAsFixed(widget.decimalDigits)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return value.toInt().toString();
  }

  void _convertNum() {
    final raw = _textController.text.replaceAll(',', '');
    if (_allowDecimal) {
      numberValue = double.tryParse(raw) ?? 0;
    } else {
      numberValue = int.tryParse(raw) ?? 0;
    }
  }

  num _roundToDecimals(num value) {
    if (!_allowDecimal) return value;
    final factor = _pow10(widget.decimalDigits);
    return (value * factor).round() / factor;
  }

  int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  int get maxLength {
    switch (widget.textFieldType ?? TextFormFieldType.all) {
      case TextFormFieldType.bigPrice:
        return 15;
      case TextFormFieldType.volume:
        return 8;
      case TextFormFieldType.price:
        return 7;
      case TextFormFieldType.twoLen:
        return 2;
      case TextFormFieldType.threeLen:
        return 3;
      default:
        return 16;
    }
  }

  bool _exceedsMax(num value) {
    if (!_allowDecimal) {
      return value.toInt().toString().length > maxLength;
    }
    final integerPartLength = value.truncate().abs().toString().length;
    return integerPartLength > maxLength;
  }
}
