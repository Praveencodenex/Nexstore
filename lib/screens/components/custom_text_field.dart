// custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thenexstore/utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final Color? cursorColor;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final double borderWidth;
  final double focusedBorderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final bool filled;
  final bool isDense;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;

  const CustomTextField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.style,
    this.hintStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.inputFormatters,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.cursorColor,
    this.fillColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.errorBorderColor,
    this.borderRadius = 30.0,
    this.borderWidth = 0.0,
    this.focusedBorderWidth = 1.5,
    this.contentPadding,
    this.filled = true,
    this.isDense = false,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onEditingComplete,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _updateHasText() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 3.0),
            child: Text(
              widget.label!,
              style: widget.labelStyle ?? bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
            ),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            readOnly: widget.readOnly,

            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            style: widget.style ?? const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            cursorColor: widget.cursorColor ?? Colors.black,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              errorText: widget.errorText,
              hintStyle: widget.hintStyle ?? const TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
              errorStyle: widget.errorStyle,
              helperStyle: widget.helperStyle,
              prefixIcon: widget.prefixIcon,
              suffixIcon: _hasText
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _controller.clear();
                  if (widget.onChanged != null) {
                    widget.onChanged!('');
                  }
                },
              )
                  : widget.suffix,
              prefix: widget.prefix,
              prefixText: widget.prefixText,
              suffixText: widget.suffixText,
              filled: widget.filled,
              fillColor: widget.fillColor ?? Colors.white,
              isDense: widget.isDense,
              contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: _buildBorder(),
              enabledBorder: _buildBorder(
                color: kWhiteColor,
              ),
              focusedBorder: _buildBorder(
                color: kWhiteColor,
                width: widget.focusedBorderWidth,
              ),
              errorBorder: _buildBorder(
                color: widget.errorBorderColor ?? Colors.red,
              ),
              focusedErrorBorder: _buildBorder(
                color: widget.errorBorderColor ?? Colors.red,
                width: widget.focusedBorderWidth,
              ),
              disabledBorder: _buildBorder(
                color: Colors.transparent,
              ),
            ),
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            onTapOutside: widget.onTapOutside,
            onEditingComplete: widget.onEditingComplete,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder({Color? color, double? width}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(35),
      borderSide: BorderSide(
        color:  Colors.transparent,

        width: width ?? widget.borderWidth,
      ),
    );
  }
}