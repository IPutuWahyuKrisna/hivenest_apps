/// Pasangan jenis lebah dan jenis madu.
///
/// Jenis madu tidak dipilih sendiri oleh peternak — nilainya sudah melekat
/// pada jenis lebahnya. Karena itu form hanya menyediakan dropdown untuk
/// [beeSpecies], dan [honeyType] ikut terisi otomatis.
class BeeSpeciesOption {
  /// Nilai yang dikirim ke API sebagai `bee_species`.
  final String beeSpecies;

  /// Nilai yang dikirim ke API sebagai `honey_type`.
  final String honeyType;

  /// Nama lain untuk lebahnya yang dikenal di lapangan. Sengaja dijaga
  /// pendek supaya muat satu baris di dropdown, dan hanya untuk ditampilkan —
  /// tidak pernah dikirim ke server.
  final String aliases;

  const BeeSpeciesOption({
    required this.beeSpecies,
    required this.honeyType,
    required this.aliases,
  });
}

class BeeSpeciesOptions {
  BeeSpeciesOptions._();

  static const List<BeeSpeciesOption> all = [
    BeeSpeciesOption(
      beeSpecies: 'Lebah lokal',
      honeyType: 'Madu nyawan',
      aliases: 'nyawan, tawon',
    ),
    BeeSpeciesOption(
      beeSpecies: 'Kele-kele',
      honeyType: 'Madu kele-kele',
      aliases: 'klanceng, lebah tanpa sengat',
    ),
    BeeSpeciesOption(
      beeSpecies: 'Lebah hutan',
      honeyType: 'Madu hutan',
      aliases: 'lebah madu raksasa',
    ),
    BeeSpeciesOption(
      beeSpecies: 'Lebah lokal Tenganan',
      honeyType: 'Madu lokal Tenganan',
      aliases: '',
    ),
  ];

  /// Mencari opsi berdasarkan nilai `bee_species` yang tersimpan.
  ///
  /// Mengembalikan null kalau nilainya di luar daftar — misalnya data lama
  /// yang dulu diisi bebas. Form edit memakai ini untuk mengosongkan dropdown
  /// dan meminta peternak memilih ulang.
  static BeeSpeciesOption? findByBeeSpecies(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final needle = value.trim().toLowerCase();
    for (final option in all) {
      if (option.beeSpecies.toLowerCase() == needle) return option;
    }
    return null;
  }
}
