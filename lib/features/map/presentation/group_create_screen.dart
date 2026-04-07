import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/constants/campus_constants.dart';
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

  void _pickLocation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '장소 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: _selectedLocation ??
                        const NLatLng(
                          CampusConstants.latitude,
                          CampusConstants.longitude,
                        ),
                    zoom: 16,
                  ),
                  mapType: NMapType.basic,
                ),
                onMapTapped: (point, latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '모임 수정' : '모임 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '모임 이름',
                  hintText: '예: 알고리즘 스터디',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? '모임 이름을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: GroupCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c.label,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),

              // Max members
              Row(
                children: [
                  const Text('최대 인원'),
                  const Spacer(),
                  IconButton(
                    onPressed: _maxMembers > 2
                        ? () => setState(() => _maxMembers--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_maxMembers명',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _maxMembers < 20
                        ? () => setState(() => _maxMembers++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Location picker
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(
                  _selectedLocation != null ? '장소 선택됨' : '지도에서 장소 선택',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: '장소 이름',
                  hintText: '예: 공대 3호관 스터디룸',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? '장소 이름을 입력해주세요' : null,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? '수정하기' : '모임 만들기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
