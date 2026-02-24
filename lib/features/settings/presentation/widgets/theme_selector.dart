import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ThemeOption(
            icon: LucideIcons.sun,
            label: 'Light',
            isSelected: false,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThemeOption(
            icon: LucideIcons.moon,
            label: 'Dark',
            isSelected: true,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ThemeOption(
            icon: LucideIcons.monitor_smartphone,
            label: 'System',
            isSelected: false,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(20)
              : colorScheme.secondary.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSecondary.withAlpha(150),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSecondary.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
