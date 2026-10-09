class UserData {
  final String email;
  final int points;
  final String title;

  UserData({
    required this.email,
    required this.points,
    required this.title,
  });

  static String calculateTitle(int points) {
    if (points < 100) {
      return 'Tân Binh Khám Phá 🛡️';
    }
    if (points >= 300) {
      return 'Hậu Duệ Lạc Hồng 🌟';
    }
    return 'Người Gác Thành Đội Viên ⚔️';
  }
}
