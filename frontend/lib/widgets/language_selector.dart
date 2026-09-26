import 'package:flutter/material.dart';
import '../theme.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageSelector extends StatelessWidget {
  final String value;
  final List<LanguageOption> options;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool showFlag;

  const LanguageSelector({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
    this.showFlag = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption = options.firstWhere(
      (o) => o.code == value,
      orElse: () => options.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary,
                size: 24,
              ),
              dropdownColor: AppTheme.surface,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.code,
                  child: Row(
                    children: [
                      if (showFlag) ...[
                        Text(option.flag, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                      ],
                      Text(option.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => onChanged(v ?? value),
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageSelectorModal extends StatelessWidget {
  final String currentLanguage;
  final List<LanguageOption> languages;
  final ValueChanged<String> onSelect;

  const LanguageSelectorModal({
    super.key,
    required this.currentLanguage,
    required this.languages,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Choisir une langue',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: languages.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = lang.code == currentLanguage;
                return ListTile(
                  leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    lang.name,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryViolet : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryViolet, size: 24)
                      : null,
                  onTap: () {
                    onSelect(lang.code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}