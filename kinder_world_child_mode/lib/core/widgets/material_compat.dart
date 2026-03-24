import 'package:flutter/material.dart';

class DropdownButtonFormFieldCompat<T> extends StatelessWidget {
  const DropdownButtonFormFieldCompat({
    super.key,
    this.initialValue,
    required this.items,
    this.selectedItemBuilder,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.decoration,
    this.hint,
    this.disabledHint,
    this.isDense = false,
    this.isExpanded = false,
    this.autofocus = false,
    this.focusNode,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.itemHeight,
    this.style,
    this.dropdownColor,
    this.menuMaxHeight,
    this.alignment = AlignmentDirectional.centerStart,
    this.borderRadius,
    this.padding,
    this.enableFeedback,
    this.barrierDismissible,
  });

  final T? initialValue;
  final List<DropdownMenuItem<T>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  final ValueChanged<T?>? onChanged;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;
  final InputDecoration? decoration;
  final Widget? hint;
  final Widget? disabledHint;
  final bool isDense;
  final bool isExpanded;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double iconSize;
  final double? itemHeight;
  final TextStyle? style;
  final Color? dropdownColor;
  final double? menuMaxHeight;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool? enableFeedback;
  final bool? barrierDismissible;

  @override
  Widget build(BuildContext context) {
    final namedArguments = <Symbol, dynamic>{
      if (key != null) #key: key,
      #items: items,
      if (selectedItemBuilder != null) #selectedItemBuilder: selectedItemBuilder,
      if (onChanged != null) #onChanged: onChanged,
      if (onSaved != null) #onSaved: onSaved,
      if (validator != null) #validator: validator,
      if (decoration != null) #decoration: decoration,
      if (hint != null) #hint: hint,
      if (disabledHint != null) #disabledHint: disabledHint,
      #isDense: isDense,
      #isExpanded: isExpanded,
      #autofocus: autofocus,
      if (focusNode != null) #focusNode: focusNode,
      if (icon != null) #icon: icon,
      if (iconDisabledColor != null) #iconDisabledColor: iconDisabledColor,
      if (iconEnabledColor != null) #iconEnabledColor: iconEnabledColor,
      #iconSize: iconSize,
      if (itemHeight != null) #itemHeight: itemHeight,
      if (style != null) #style: style,
      if (dropdownColor != null) #dropdownColor: dropdownColor,
      if (menuMaxHeight != null) #menuMaxHeight: menuMaxHeight,
      #alignment: alignment,
      if (borderRadius != null) #borderRadius: borderRadius,
      if (padding != null) #padding: padding,
      if (enableFeedback != null) #enableFeedback: enableFeedback,
      if (barrierDismissible != null)
        #barrierDismissible: barrierDismissible,
    };

    try {
      return Function.apply(
            DropdownButtonFormField<T>.new,
            const [],
            <Symbol, dynamic>{
              ...namedArguments,
              #initialValue: initialValue,
            },
          )
          as Widget;
    } on NoSuchMethodError {
      return Function.apply(
            DropdownButtonFormField<T>.new,
            const [],
            <Symbol, dynamic>{
              ...namedArguments,
              #value: initialValue,
            },
          )
          as Widget;
    }
  }
}

class SwitchListTileCompat extends StatelessWidget {
  const SwitchListTileCompat({
    super.key,
    this.contentPadding,
    this.secondary,
    this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeThumbColor,
  });

  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeThumbColor;

  @override
  Widget build(BuildContext context) {
    final namedArguments = <Symbol, dynamic>{
      if (key != null) #key: key,
      if (contentPadding != null) #contentPadding: contentPadding,
      if (secondary != null) #secondary: secondary,
      if (title != null) #title: title,
      if (subtitle != null) #subtitle: subtitle,
      #value: value,
      #onChanged: onChanged,
    };

    try {
      return Function.apply(
            SwitchListTile.new,
            const [],
            <Symbol, dynamic>{
              ...namedArguments,
              if (activeThumbColor != null) #activeThumbColor: activeThumbColor,
            },
          )
          as Widget;
    } on NoSuchMethodError {
      return Function.apply(
            SwitchListTile.new,
            const [],
            <Symbol, dynamic>{
              ...namedArguments,
              if (activeThumbColor != null) #activeColor: activeThumbColor,
            },
          )
          as Widget;
    }
  }
}
