import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/profile/cubit/profile_edit_state.dart';

class ProfileHeaderCard extends StatefulWidget {
  final User? user;

  const ProfileHeaderCard({super.key, required this.user});

  @override
  State<ProfileHeaderCard> createState() => _ProfileHeaderCardState();
}

class _ProfileHeaderCardState extends State<ProfileHeaderCard> {
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _bioController = TextEditingController(text: widget.user?.bio ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user && !_isEditing) {
      _nameController.text = widget.user?.name ?? '';
      _bioController.text = widget.user?.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<ProfileEditCubit>().updateProfile(
          name: name,
          bio: _bioController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listener: (context, state) {
        if (state is ProfileEditSuccess) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileEditLoading;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'ProjectHub User',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded),
                      tooltip: _isEditing ? 'Cancel' : 'Edit profile',
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                    ),
                  ],
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _nameController,
                    label: 'Display Name',
                    hintText: 'Your full name',
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hintText: 'Short description about yourself',
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: AppButton(
                        label: 'Save Profile',
                        icon: Icons.check_rounded,
                        isLoading: isLoading,
                        onPressed: () => _save(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
