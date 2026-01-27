import 'package:flutter/material.dart';
import 'package:gift_collab/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final double? width;
  final double? height;
  final double? buttonRadius;
  final double? textSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool isDisabled;
  final bool isOutlined;
  final IconData? leadingIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.buttonRadius,
    this.textSize,
    this.fontWeight,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.isLoading = false,
    this.isDisabled = false,
    this.isOutlined = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = !isDisabled && !isLoading;
    // Determine the active colors
    final Color bgColor = backgroundColor ??
        (isOutlined ? Colors.transparent : AppColors.primaryPurple);
    final Color fgColor = foregroundColor ??
        (isOutlined ? AppColors.primaryPurple : Colors.white);
    final Color iconColor = foregroundColor ??
        (isOutlined ? AppColors.primaryPurple : Colors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 51,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withOpacity(0.5),
          disabledForegroundColor: fgColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius ?? 40),
            side: isOutlined
                ? const BorderSide(color: AppColors.primaryPurple)
                : BorderSide.none,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Visible Icon on the Left
                  if (leadingIcon != null)
                    Icon(
                      leadingIcon,
                      size: 20,
                      color: iconColor,
                    ),

                  // 2. The Text (Expanded ensures it takes up center space)
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Prevents overflow error
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: textSize ?? 16,
                        fontWeight: fontWeight ?? FontWeight.w500,
                        color: fgColor,
                      ),
                    ),
                  ),

                  // 3. Invisible Icon on the Right (Balances the layout)
                  if (leadingIcon != null)
                    Opacity(
                      opacity: 0.0,
                      child: Icon(
                        leadingIcon,
                        size: 20,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}