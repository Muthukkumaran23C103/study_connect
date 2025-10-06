import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final ButtonType type;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enabled;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.isLoading = false,
    this.type = ButtonType.elevated,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  });

  const CustomButton.primary({
    super.key,
    this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  }) : type = ButtonType.elevated;

  const CustomButton.secondary({
    super.key,
    this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  }) : type = ButtonType.outlined;

  const CustomButton.text({
    super.key,
    this.onPressed,
    required this.child,
    this.isLoading = false,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.padding,
    this.borderRadius,
    this.enabled = true,
  }) : type = ButtonType.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !enabled || isLoading || onPressed == null;

    // Get size properties
    final sizeProps = _getSizeProperties(size);

    // Get effective padding
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: sizeProps.horizontalPadding,
      vertical: sizeProps.verticalPadding,
    );

    // Get effective border radius
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    Widget buttonChild = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
        height: sizeProps.iconSize,
        width: sizeProps.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.elevated
                ? (foregroundColor ?? theme.colorScheme.onPrimary)
                : (foregroundColor ?? theme.colorScheme.primary),
          ),
        ),
      )
          : DefaultTextStyle(
        style: theme.textTheme.labelLarge!.copyWith(
          fontSize: sizeProps.fontSize,
          fontWeight: FontWeight.w600,
        ),
        child: child,
      ),
    );

    Widget button;

    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
            disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
            elevation: isDisabled ? 0 : 2,
            shadowColor: theme.colorScheme.shadow,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            minimumSize: Size.zero,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
            side: BorderSide(
              color: isDisabled
                  ? theme.colorScheme.onSurface.withOpacity(0.12)
                  : (backgroundColor ?? theme.colorScheme.primary),
              width: 1.5,
            ),
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            minimumSize: Size.zero,
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
            backgroundColor: backgroundColor,
            padding: effectivePadding,
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            minimumSize: Size.zero,
          ),
          child: buttonChild,
        );
        break;
    }

    if (width != null) {
      button = SizedBox(
        width: width,
        child: button,
      );
    }

    return button;
  }

  _ButtonSizeProperties _getSizeProperties(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonSizeProperties(
          horizontalPadding: 16,
          verticalPadding: 8,
          fontSize: 14,
          iconSize: 16,
        );
      case ButtonSize.medium:
        return const _ButtonSizeProperties(
          horizontalPadding: 24,
          verticalPadding: 12,
          fontSize: 16,
          iconSize: 20,
        );
      case ButtonSize.large:
        return const _ButtonSizeProperties(
          horizontalPadding: 32,
          verticalPadding: 16,
          fontSize: 18,
          iconSize: 24,
        );
    }
  }
}

enum ButtonType {
  elevated,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class _ButtonSizeProperties {
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;

  const _ButtonSizeProperties({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });
}

// Icon Button variant
class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;
  final ButtonType type;
  final ButtonSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool enabled;

  const CustomIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.type = ButtonType.elevated,
    this.size = ButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !enabled || isLoading || onPressed == null;

    final sizeProps = _getSizeProperties(size);

    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
        height: sizeProps.iconSize * 0.8,
        width: sizeProps.iconSize * 0.8,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.elevated
                ? (foregroundColor ?? theme.colorScheme.onPrimary)
                : (foregroundColor ?? theme.colorScheme.primary),
          ),
        ),
      )
          : Icon(
        icon,
        size: sizeProps.iconSize,
      ),
    );

    Widget button;

    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
            padding: EdgeInsets.all(sizeProps.verticalPadding),
            shape: const CircleBorder(),
            minimumSize: Size.zero,
          ),
          child: iconWidget,
        );
        break;

      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: backgroundColor ?? theme.colorScheme.primary,
              width: 1.5,
            ),
            padding: EdgeInsets.all(sizeProps.verticalPadding),
            shape: const CircleBorder(),
            minimumSize: Size.zero,
          ),
          child: iconWidget,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? theme.colorScheme.primary,
            backgroundColor: backgroundColor,
            padding: EdgeInsets.all(sizeProps.verticalPadding),
            shape: const CircleBorder(),
            minimumSize: Size.zero,
          ),
          child: iconWidget,
        );
        break;
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  _ButtonSizeProperties _getSizeProperties(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return const _ButtonSizeProperties(
          horizontalPadding: 8,
          verticalPadding: 8,
          fontSize: 14,
          iconSize: 16,
        );
      case ButtonSize.medium:
        return const _ButtonSizeProperties(
          horizontalPadding: 12,
          verticalPadding: 12,
          fontSize: 16,
          iconSize: 20,
        );
      case ButtonSize.large:
        return const _ButtonSizeProperties(
          horizontalPadding: 16,
          verticalPadding: 16,
          fontSize: 18,
          iconSize: 24,
        );
    }
  }
}