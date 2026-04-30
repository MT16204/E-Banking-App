import 'package:banking_app/core/l10n/app_lang.dart';
import 'package:banking_app/core/theme/colors.dart';
import 'package:banking_app/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class TransferSpendingCategory {
  final String id;
  final String label;
  final IconData icon;

  const TransferSpendingCategory({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class TransferNoteCard extends StatelessWidget {
  final TextEditingController noteController;
  final List<TransferSpendingCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategoryChanged;

  const TransferNoteCard({
    super.key,
    required this.noteController,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = NovaTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Nội dung', 'Description'),
            style: NovaFonts.body.copyWith(
              color: theme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: noteController,
            maxLength: 150,
            style: NovaFonts.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterStyle: NovaFonts.body.copyWith(
                fontSize: 11,
                color: theme.textSecondary,
              ),
              hintText: context.tr(
                'Nhập nội dung chuyển tiền',
                'Enter transfer note',
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Text(
            context.tr('Danh mục chi tiêu', 'Spending category'),
            style: NovaFonts.body.copyWith(
              color: theme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              final isSelected = selectedCategoryId == category.id;
              return GestureDetector(
                onTap: () => onCategoryChanged(isSelected ? null : category.id),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primary : theme.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.primary : theme.primaryMid,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        size: 20,
                        color: isSelected ? Colors.white : theme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.label,
                      textAlign: TextAlign.center,
                      style: NovaFonts.body.copyWith(
                        fontSize: 10,
                        color: isSelected ? theme.primary : theme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
