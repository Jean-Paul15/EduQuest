import 'package:eduquest/features/user/data/user_profile_repository.dart';
import 'package:eduquest/features/user/domain/user_profile.dart';

class FakeUserProfileRepository extends UserProfileRepository {
  FakeUserProfileRepository(this.profile);

  UserProfile profile;
  String? lastPhone;

  @override
  Future<UserProfile> load() async => profile;

  @override
  Future<bool> saveWhatsappPhone(String phone) async {
    lastPhone = phone;
    profile = UserProfile(
      displayName: profile.displayName,
      email: profile.email,
      countryCode: profile.countryCode,
      levelCode: profile.levelCode,
      serieCode: profile.serieCode,
      whatsappPhone: phone,
    );
    return true;
  }
}
