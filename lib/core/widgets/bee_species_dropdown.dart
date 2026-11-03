import 'package:flutter/material.dart';
import '../constants/bee_species_options.dart';
import '../theme/app_theme.dart';

/// Dropdown pemilih jenis lebah, dipakai bersama oleh form tambah dan edit
/// sarang. Jenis madu tidak dipilih di sini — lihat [HoneyTypeField].
class BeeSpeciesDropdown extends StatelessWidget {
  final BeeSpeciesOption? value;
  final ValueChanged<BeeSpeciesOption?> onChanged;

  /// Ditampilkan kalau data lama punya jenis lebah di luar daftar, supaya
  /// peternak paham kenapa pilihannya kosong.
  final String? warning;

  const BeeSpeciesDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.bug_report_outlined,
                  color: AppColors.textGray, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<BeeSpeciesOption>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textGray),
                  hint: const Text(
                    'Pilih Jenis Lebah',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                  // Tinggi bawaan item cuma 48px, tidak cukup untuk dua baris
                  // sehingga alias sempat menabrak item di bawahnya.
                  itemHeight: 60,
                  dropdownColor: Colors.white,
                  elevation: 3,
                  borderRadius: BorderRadius.circular(14),
                  // Yang tampil di kolom tertutup cukup nama bakunya saja,
                  // alias hanya muncul saat daftar dibuka.
                  selectedItemBuilder: (_) => BeeSpeciesOptions.all
                      .map(
                        (option) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option.beeSpecies,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  items: BeeSpeciesOptions.all.map((option) {
                    final isSelected = option.beeSpecies == value?.beeSpecies;
                    return DropdownMenuItem<BeeSpeciesOption>(
                      value: option,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.beeSpecies,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.2,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDark,
                            ),
                          ),
                          if (option.aliases.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              option.aliases,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.2,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
        if (warning != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 14, color: AppColors.statusAmberText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  warning!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.statusAmberText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Menampilkan jenis madu yang mengikuti jenis lebah terpilih. Sengaja tidak
/// bisa diketik karena pasangannya sudah ditentukan.
class HoneyTypeField extends StatelessWidget {
  final String? honeyType;

  const HoneyTypeField({super.key, required this.honeyType});

  @override
  Widget build(BuildContext context) {
    final hasValue = honeyType != null && honeyType!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined,
              color: AppColors.textGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasValue
                  ? honeyType!
                  : 'Jenis madu mengikuti jenis lebah',
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? AppColors.textDark : AppColors.textGray,
              ),
            ),
          ),
          const Icon(Icons.lock_outline, size: 16, color: AppColors.textGray),
        ],
      ),
    );
  }
}
