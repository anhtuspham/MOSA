import 'package:flutter/material.dart';
import 'package:mosa/config/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChange;
  final String hintText;
  final Function()? onClear;
  const SearchBarWidget({
    super.key,
    this.hintText = 'Tìm theo tên hạng mục',
    required this.onChange,
    required this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController controller;
  bool _hasText = false;

  @override
  initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(() {
      setState(() {
        _hasText = controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: widget.onChange,
      decoration: InputDecoration(
        suffixIcon:
            _hasText
                ? IconButton(
                  onPressed: () {
                    controller.clear();
                    setState(() => _hasText = false);
                    widget.onClear?.call();
                  },
                  icon: Icon(Icons.close),
                )
                : null,
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.outlineVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        hintText: widget.hintText,
      ),
      keyboardType: TextInputType.text,
    );
  }
}
