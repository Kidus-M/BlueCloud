import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isFocused ? AppColors.primary : AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (focused) {
              setState(() => _isFocused = focused);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: DropdownButtonFormField<String>(
                value: widget.value,
                validator: widget.validator,
                decoration: InputDecoration(
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused ? AppColors.primary : AppColors.grey,
                          size: 20,
                        )
                      : null,
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.grey),
                isExpanded: true,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.dark,
                ),
                items: widget.items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
