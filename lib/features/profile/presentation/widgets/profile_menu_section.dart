import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import 'logout_confirmation_dialog.dart';

class ProfileMenuSection extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  const ProfileMenuSection({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      _InfoField(label: 'Nama', value: user.name),
      _InfoField(label: 'Email', value: user.email),
      _InfoField(label: 'Username', value: user.username),
      _InfoField(label: 'Role', value: user.role),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _MenuCard(
            children: [
              ...fields.asMap().entries.map((e) => _InfoTile(
                    field: e.value,
                    showDivider: e.key < fields.length - 1,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          _MenuCard(
            children: [
              _MenuTile(
                item: const _MenuItem(
                  icon: Icons.logout,
                  label: 'Keluar',
                  isDestructive: true,
                ),
                showDivider: false,
                onTap: () => LogoutConfirmationDialog.show(context, onLogout),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool showDivider;
  final VoidCallback? onTap;
  const _MenuTile({
    required this.item,
    required this.showDivider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive ? Colors.red : AppColors.textDark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(item.icon, size: 22, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: item.isDestructive
                      ? Colors.red.withValues(alpha: 0.5)
                      : AppColors.textGray,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 52, color: AppColors.fieldBg),
      ],
    );
  }
}

class _InfoField {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});
}

class _InfoTile extends StatelessWidget {
  final _InfoField field;
  final bool showDivider;
  const _InfoTile({required this.field, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                field.label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  field.value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, color: AppColors.fieldBg),
      ],
    );
  }
}
