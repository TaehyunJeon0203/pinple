import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupCreateScreen extends ConsumerStatefulWidget {
  final String? groupId; // null for create, non-null for edit

  const GroupCreateScreen({super.key, this.groupId});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends ConsumerState<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController();
  String _selectedCategory = GroupCategory.study.label;
  int _maxMembers = 4;
  NLatLng? _selectedLocation;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _isEditMode = true;
      _loadGroupData();
    }
  }

  Future<void> _loadGroupData() async {
    final group = await ref
        .read(groupRepositoryProvider)
        .getGroupById(widget.groupId!);
    if (group != null && mounted) {
      setState(() {
        _titleController.text = group.title;
        _descriptionController.text = group.description;
        _locationNameController.text = group.locationName;
        _selectedCategory = group.category;
        _maxMembers = group.maxMembers;
        _selectedLocation = NLatLng(group.latitude, group.longitude);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모임 장소를 선택해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData =
          await ref.read(authRepositoryProvider).getUserData(user.uid);

      if (_isEditMode) {
        await ref.read(groupRepositoryProvider).updateGroup(widget.groupId!, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory,
          'maxMembers': _maxMembers,
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'locationName': _locationNameController.text.trim(),
        });
      } else {
        final group = GroupModel(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          maxMembers: _maxMembers,
          memberIds: [user.uid],
          ownerId: user.uid,
          ownerNickname: userData?['displayName'] ?? '',
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          locationName: _locationNameController.text.trim(),
          createdAt: DateTime.now(),
        );
        await ref.read(groupRepositoryProvider).createGroup(group);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    final picked = await showModalBottomSheet<NLatLng>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LocationPickerSheet(
        initialLocation: _selectedLocation,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedLocation = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '모임 수정' : '모임 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isEditMode) ...[
                PageHeader(
                  title: '어떤 모임이에요?',
                  subtitle: '카테고리와 인원을 정해주세요',
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                ),
              ],

              // 모임 이름
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '모임 이름',
                  hintText: '예: 알고리즘 스터디',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? '모임 이름을 입력해주세요' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 카테고리
              Text(
                '카테고리',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: GroupCategory.values.map((c) {
                  return _CategoryOption(
                    label: c.label,
                    isSelected: _selectedCategory == c.label,
                    onTap: () => setState(() => _selectedCategory = c.label),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 최대 인원 stepper
              Text(
                '최대 인원',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    onPressed: _maxMembers > 2
                        ? () => setState(() => _maxMembers--)
                        : null,
                  ),
                  Expanded(
                    child: Text(
                      '$_maxMembers명',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    onPressed: _maxMembers < 20
                        ? () => setState(() => _maxMembers++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // 모임 설명
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '모임 설명',
                  hintText: '어떤 모임인지 설명해주세요',
                ),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? '설명을 입력해주세요' : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 장소 선택 버튼
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: Icon(
                  _selectedLocation != null
                      ? Icons.check_rounded
                      : Icons.map_rounded,
                ),
                label: Text(
                  _selectedLocation != null
                      ? '장소 선택됨 · 변경하기'
                      : '지도에서 장소 선택',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 장소 이름
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: '장소 이름',
                  hintText: '예: 공대 3호관 스터디룸',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? '장소 이름을 입력해주세요' : null,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // 제출 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const AppLoader(color: Colors.white)
                    : Text(_isEditMode ? '수정하기' : '모임 만들기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(label);
    final icon = categoryIcon(label);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.fill,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.textSubtle,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? color : AppColors.text,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: isEnabled ? AppColors.border : AppColors.borderSubtle,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          foregroundColor:
              isEnabled ? AppColors.textStrong : AppColors.textDisabled,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  final NLatLng? initialLocation;

  const _LocationPickerSheet({this.initialLocation});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  NaverMapController? _mapController;
  NLatLng? _selected;
  static const _markerId = 'selected-location';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  Future<void> _updateMarker(NLatLng latLng) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.clearOverlays();
    await controller.addOverlay(
      NMarker(
        id: _markerId,
        position: latLng,
        iconTintColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = _selected != null;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Text('장소 선택', style: theme.textTheme.titleMedium),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  hasSelection ? '· 선택됨' : '· 지도를 탭하세요',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: hasSelection
                      ? () => Navigator.pop(context, _selected)
                      : null,
                  child: const Text('완료'),
                ),
              ],
            ),
          ),
          Expanded(
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _selected ??
                      const NLatLng(
                        CampusConstants.latitude,
                        CampusConstants.longitude,
                      ),
                  zoom: 16,
                ),
                mapType: NMapType.basic,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                final initial = _selected;
                if (initial != null) {
                  _updateMarker(initial);
                }
              },
              onMapTapped: (point, latLng) {
                setState(() => _selected = latLng);
                _updateMarker(latLng);
              },
            ),
          ),
        ],
      ),
    );
  }
}
