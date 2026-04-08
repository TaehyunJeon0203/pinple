import 'package:pinple/core/constants/campus_constants.dart';

bool isValidKongjuEmail(String email) {
  return email.endsWith('@${CampusConstants.emailDomain}');
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return '이메일을 입력해주세요';
  if (!isValidKongjuEmail(value)) {
    return '학번@${CampusConstants.emailDomain} 형식만 사용 가능합니다';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
  if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다';
  return null;
}

String? validateNickname(String? value) {
  if (value == null || value.isEmpty) return '닉네임을 입력해주세요';
  if (value.length < 2 || value.length > 10) return '닉네임은 2~10자여야 합니다';
  return null;
}
