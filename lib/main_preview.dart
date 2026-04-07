import 'package:flutter/material.dart';
import 'package:pinple/core/constants/app_constants.dart';
import 'package:pinple/core/theme/app_theme.dart';

void main() {
  runApp(const PinplePreview());
}

class PinplePreview extends StatelessWidget {
  const PinplePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinple Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PreviewHome(),
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinple 미리보기')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _navButton(context, '로그인', const _PreviewLoginScreen()),
          _navButton(context, '회원가입', const _PreviewSignUpScreen()),
          _navButton(context, '이메일 인증', const _PreviewEmailVerifyScreen()),
          _navButton(context, '위치 차단', const _PreviewLocationBlocked()),
          _navButton(context, '지도 (메인)', const _PreviewMapScreen()),
          _navButton(context, '모임 상세', const _PreviewGroupDetail()),
          _navButton(context, '모임 만들기', const _PreviewGroupCreate()),
          _navButton(context, '마이페이지', const _PreviewProfile()),
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        ),
        child: Text(title),
      ),
    );
  }
}

// ─── 로그인 ───
class _PreviewLoginScreen extends StatelessWidget {
  const _PreviewLoginScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 80,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text('Pinple',
                    style: Theme.of(context).textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('공주대학교 천안캠퍼스',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey)),
                const SizedBox(height: 48),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '학교 이메일',
                    hintText: '학번@smail.kongju.ac.kr',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('로그인'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _PreviewSignUpScreen())),
                  child: const Text('계정이 없으신가요? 회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 회원가입 ───
class _PreviewSignUpScreen extends StatelessWidget {
  const _PreviewSignUpScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: '학번',
                hintText: '202012345',
                prefixIcon: Icon(Icons.badge_outlined),
                suffixText: '@smail.kongju.ac.kr',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: '2~10자',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '비밀번호',
                hintText: '6자 이상',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '비밀번호 확인',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 이메일 인증 ───
class _PreviewEmailVerifyScreen extends StatelessWidget {
  const _PreviewEmailVerifyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 80,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text('이메일 인증',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('학교 이메일로 인증 메일을 보냈습니다.\n메일함을 확인해주세요.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text('인증 완료 확인'),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: () {}, child: const Text('인증 메일 다시 보내기')),
              const SizedBox(height: 8),
              TextButton(onPressed: () {}, child: const Text('다른 계정으로 로그인')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 위치 차단 ───
class _PreviewLocationBlocked extends StatelessWidget {
  const _PreviewLocationBlocked();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text('캠퍼스 근처에서만\n사용할 수 있습니다',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('공주대학교 천안캠퍼스 반경 2km 이내에서 이용해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('다시 확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 지도 (메인) ───
class _PreviewMapScreen extends StatelessWidget {
  const _PreviewMapScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 placeholder
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('네이버 지도 영역',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text('(네이버맵 Client ID 설정 후 표시됨)',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          // 샘플 핀들
          Positioned(
            top: 200, left: 100,
            child: GestureDetector(
              onTap: () => _showSampleBottomSheet(context, '알고리즘 스터디', '스터디', '공대 3호관'),
              child: const _SamplePin(label: '알고리즘 스터디', color: Colors.blue),
            ),
          ),
          Positioned(
            top: 320, left: 220,
            child: GestureDetector(
              onTap: () => _showSampleBottomSheet(context, '풋살 같이해요', '운동', '대운동장'),
              child: const _SamplePin(label: '풋살 같이해요', color: Colors.green),
            ),
          ),
          Positioned(
            top: 260, left: 50,
            child: GestureDetector(
              onTap: () => _showSampleBottomSheet(context, '점심 밥약', '밥약', '학생식당 앞'),
              child: const _SamplePin(label: '점심 밥약', color: Colors.orange),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const _PreviewGroupCreate())),
        icon: const Icon(Icons.add),
        label: const Text('모임 만들기'),
      ),
    );
  }

  void _showSampleBottomSheet(BuildContext context, String title, String category, String location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(category, style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                Text('3/4명', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(location, style: TextStyle(color: Colors.grey[600])),
            ]),
            const SizedBox(height: 8),
            const Text('매주 수요일 7시에 모여서 알고리즘 문제 풀어요!'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const _PreviewGroupDetail()));
                },
                child: const Text('자세히 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SamplePin extends StatelessWidget {
  final String label;
  final Color color;

  const _SamplePin({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ),
        Icon(Icons.location_on, color: color, size: 32),
      ],
    );
  }
}

// ─── 모임 상세 ───
class _PreviewGroupDetail extends StatelessWidget {
  const _PreviewGroupDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 상세'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('스터디'),
                ),
                const Spacer(),
                Icon(Icons.people, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('3/6명', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text('알고리즘 스터디',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('공대 3호관 스터디룸', style: TextStyle(color: Colors.grey[600])),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.person, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text('만든 사람: 코딩왕', style: TextStyle(color: Colors.grey[600])),
            ]),
            const SizedBox(height: 20),
            Text('매주 수요일 저녁 7시에 모여서 백준/프로그래머스 문제를 함께 풀어요.\n실력 상관없이 누구나 환영합니다!',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),

            // 참여 신청 목록 (모임장 뷰)
            const Text('참여 신청 (2)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: const Text('김공주'),
                subtitle: const Text('참여하고 싶습니다!'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('이천안'),
                subtitle: const Text('같이 공부해요~'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('참여 신청'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 모임 만들기 ───
class _PreviewGroupCreate extends StatefulWidget {
  const _PreviewGroupCreate();

  @override
  State<_PreviewGroupCreate> createState() => _PreviewGroupCreateState();
}

class _PreviewGroupCreateState extends State<_PreviewGroupCreate> {
  String _category = '스터디';
  int _maxMembers = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('모임 만들기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: '모임 이름',
                hintText: '예: 알고리즘 스터디',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: '카테고리'),
              items: GroupCategory.values
                  .map((c) => DropdownMenuItem(value: c.label, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('최대 인원'),
                const Spacer(),
                IconButton(
                  onPressed: _maxMembers > 2 ? () => setState(() => _maxMembers--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_maxMembers명',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _maxMembers < 20 ? () => setState(() => _maxMembers++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '모임 설명',
                hintText: '어떤 모임인지 설명해주세요',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text('지도에서 장소 선택'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '장소 이름',
                hintText: '예: 공대 3호관 스터디룸',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('모임 만들기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 마이페이지 ───
class _PreviewProfile extends StatelessWidget {
  const _PreviewProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 30, child: Text('홍', style: TextStyle(fontSize: 24))),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('홍길동',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('202012345@smail.kongju.ac.kr',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('내 모임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Text('스')),
                title: const Text('알고리즘 스터디'),
                subtitle: const Text('3/6명 · 공대 3호관 스터디룸'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Text('운')),
                title: const Text('풋살 같이해요'),
                subtitle: const Text('7/10명 · 대운동장'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
