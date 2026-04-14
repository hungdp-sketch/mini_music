import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_cubit.dart';
import '../models/settings_model.dart';

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  static AppLocalizations of(BuildContext context) {
    final state = context.watch<SettingsCubit>().state;
    final language = state is SettingsLoaded
        ? state.settings.language
        : AppLanguage.vietnamese;
    return AppLocalizations(language);
  }

  bool get isEnglish => language == AppLanguage.english;

  String get homeSearchHint =>
      isEnglish ? 'Search songs...' : 'Tìm kiếm bài hát...';
  String get homeSearchEmpty => isEnglish
      ? 'Search for your favorite music'
      : 'Tìm kiếm bài hát yêu thích';
  String get recentlyPlayedTitle =>
      isEnglish ? 'Recently played' : 'Nghe gần đây';
  String get seeAllLabel => isEnglish ? 'See all' : 'Xem tất cả';

  String get settingsTitle => isEnglish ? 'Settings' : 'Cài đặt';
  String get audioSettingsHeader =>
      isEnglish ? '🎵 Audio Settings' : '🎵 Cài đặt âm thanh';
  String get soundQualityTitle => isEnglish ? 'High Quality' : 'Chất lượng cao';
  String get soundQualitySubtitle => isEnglish
      ? 'Play music using the best available quality'
      : 'Phát nhạc với chất lượng tốt nhất';
  String get streamQualityTitle =>
      isEnglish ? 'Stream Quality' : 'Chất lượng stream';
  String get autoplayNextTitle =>
      isEnglish ? 'Auto-play next' : 'Phát tự động bài tiếp theo';
  String get autoplayNextSubtitle => isEnglish
      ? 'Automatically play the next song when current finishes'
      : 'Tự động phát bài tiếp theo khi bài hiện tại kết thúc';
  String get personalizationHeader =>
      isEnglish ? '🎨 Personalization' : '🎨 Xây dựng cá nhân';
  String get languageTitle => isEnglish ? 'Language' : 'Ngôn ngữ';
  String get trendingCategoryTitle =>
      isEnglish ? 'Default trending category' : 'Thể loại xu hướng mặc định';
  String get notificationsHeader =>
      isEnglish ? '🔔 Notifications' : '🔔 Thông báo';
  String get enableNotificationsTitle =>
      isEnglish ? 'Enable notifications' : 'Bật thông báo';
  String get enableNotificationsSubtitle => isEnglish
      ? 'Receive updates about new songs and app news'
      : 'Nhận thông báo về bài hát mới và cập nhật';
  String get legalHeader =>
      isEnglish ? '⚖️ Legal & Policies' : '⚖️ Pháp lý & Chính sách';
  String get privacyPolicyTitle =>
      isEnglish ? 'Privacy Policy' : 'Chính sách bảo mật';
  String get privacyPolicySubtitle => isEnglish
      ? 'View how we protect your data'
      : 'Xem cách chúng tôi bảo vệ dữ liệu của bạn';
  String get termsOfServiceTitle =>
      isEnglish ? 'Terms of Service' : 'Điều khoản dịch vụ';
  String get termsOfServiceSubtitle => isEnglish
      ? 'Read the application terms of use'
      : 'Đọc các điều khoản sử dụng của ứng dụng';
  String get aboutAppTitle => isEnglish ? 'About App' : 'Về ứng dụng';
  String get aboutAppSubtitle => isEnglish
      ? 'See information about Mini Music'
      : 'Xem thông tin về Mini Music';
  String get dangerHeader => isEnglish ? '⚠️ Danger Zone' : '⚠️ Nguy hiểm';
  String get resetSettingsTitle =>
      isEnglish ? 'Reset all settings' : 'Đặt lại tất cả cài đặt';
  String get resetSettingsSubtitle => isEnglish
      ? 'Restore all settings to default values'
      : 'Khôi phục tất cả cài đặt về mặc định';
  String get resetDialogTitle =>
      isEnglish ? 'Reset settings?' : 'Đặt lại cài đặt?';
  String get resetDialogMessage => isEnglish
      ? 'This will restore all settings to defaults. This cannot be undone.'
      : 'Điều này sẽ khôi phục tất cả cài đặt về giá trị mặc định. Không thể hoàn tác!';
  String get resetButton => isEnglish ? 'Reset' : 'Đặt lại';
  String get cancelButton => isEnglish ? 'Cancel' : 'Hủy';
  String get resetSnackBar =>
      isEnglish ? 'Settings have been reset' : 'Cài đặt đã được đặt lại';

  String get appVersionLabel =>
      isEnglish ? 'Version 1.0.0 (Build 1)' : 'Phiên bản 1.0.0 (Build 1)';
  String get aboutDescription => isEnglish
      ? 'Mini Music is your ultimate companion for discovering, streaming, and enjoying your favorite music. With access to millions of songs and a beautiful, intuitive interface, you can explore music like never before.'
      : 'Mini Music là người bạn đồng hành hoàn hảo để khám phá, phát và tận hưởng những bài hát yêu thích. Với hàng triệu bài hát và giao diện trực quan, bạn có thể khám phá âm nhạc dễ dàng hơn bao giờ hết.';
  String get featuresHeader =>
      isEnglish ? 'Featured highlights' : 'Tính năng nổi bật';
  String get featureStreamTitle =>
      isEnglish ? 'Stream from YouTube' : 'Phát nhạc từ YouTube';
  String get featureStreamSubtitle => isEnglish
      ? 'Access a massive music library from YouTube'
      : 'Truy cập vào kho nhạc khổng lồ từ YouTube';
  String get featureSearchTitle =>
      isEnglish ? 'Fast search' : 'Tìm kiếm nhanh chóng';
  String get featureSearchSubtitle => isEnglish
      ? 'Find songs, artists, and albums fast'
      : 'Tìm bài hát, nghệ sĩ, album yêu thích của bạn';
  String get featureInterfaceTitle =>
      isEnglish ? 'Modern interface' : 'Giao diện hiện đại';
  String get featureInterfaceSubtitle => isEnglish
      ? 'Beautiful mobile-first design'
      : 'Thiết kế đẹp, dễ sử dụng, tối ưu hóa cho di động';
  String get featureEqTitle => isEnglish ? 'EQ presets' : 'Bộ lọc EQ';
  String get featureEqSubtitle => isEnglish
      ? 'Customize sound to your preference'
      : 'Tùy chỉnh âm thanh theo sở thích của bạn';
  String get techHeader => isEnglish ? 'Technology used' : 'Công nghệ sử dụng';
  String get techItemDartDescription =>
      isEnglish ? 'Programming language' : 'Ngôn ngữ lập trình';
  String get techItemYoutubeDescription =>
      isEnglish ? 'Music source' : 'Nguồn cấp nhạc';
  String get techItemJustAudioDescription =>
      isEnglish ? 'Audio player' : 'Trình phát nhạc';
  String get footerCopyright => '© 2024 Mini Music. All rights reserved.';
  String get privacyPolicyContent =>
      isEnglish ? _privacyPolicyContentEn : _privacyPolicyContentVi;
  String get termsOfServiceContent =>
      isEnglish ? _termsOfServiceContentEn : _termsOfServiceContentVi;

  static const String _privacyPolicyContentVi = '''Chính sách bảo mật Mini Music

Cập nhật lần cuối: April 2024

1. Thông tin chúng tôi thu thập
- Lịch sử tìm kiếm và hành vi
- Tùy chọn phát và cài đặt
- Thông tin thiết bị (để tối ưu ứng dụng)
- Báo cáo lỗi và phân tích ứng dụng

2. Cách chúng tôi sử dụng thông tin
- Cải thiện dịch vụ và trải nghiệm người dùng
- Cung cấp đề xuất cá nhân hóa
- Phân tích hiệu suất và hành vi sử dụng
- Sửa lỗi và bảo mật

3. Bảo mật dữ liệu
Chúng tôi áp dụng biện pháp bảo mật tiêu chuẩn ngành để bảo vệ dữ liệu của bạn. Thông tin của bạn được lưu trữ an toàn và không chia sẻ với bên thứ ba mà không có sự đồng ý của bạn.

4. Quyền của bạn
Bạn có quyền:
- Truy cập dữ liệu cá nhân
- Yêu cầu xóa dữ liệu
- Từ chối phân tích
- Xuất cài đặt và tùy chọn

5. Quyền riêng tư của trẻ em
Mini Music không dành cho trẻ em dưới 13 tuổi. Chúng tôi không cố ý thu thập thông tin cá nhân từ trẻ em dưới 13 tuổi.

6. Thay đổi chính sách
Chúng tôi có thể cập nhật chính sách này theo thời gian. Mọi thay đổi sẽ được thông báo bằng cách đăng lại nội dung mới trên trang này.

7. Liên hệ
Nếu bạn có câu hỏi về chính sách bảo mật của chúng tôi, vui lòng liên hệ: support@minimusic.app

8. Lưu trữ dữ liệu
Chúng tôi lưu trữ dữ liệu của bạn miễn là tài khoản vẫn hoạt động. Bạn có thể yêu cầu xóa dữ liệu bất cứ lúc nào qua cài đặt ứng dụng.''';

  static const String _privacyPolicyContentEn = '''Mini Music Privacy Policy

Last Updated: April 2024

1. Information We Collect
- Search history and viewing habits
- Playback preferences and settings
- Device information (for app optimization)
- Crash reports and app analytics

2. How We Use Your Information
- To improve our service and user experience
- To provide personalized recommendations
- To analyze app performance and usage
- To fix bugs and security issues

3. Data Security
We implement industry-standard security measures to protect your data. Your information is stored securely and is never shared with third parties without your consent.

4. Your Rights
You have the right to:
- Access your personal data
- Request deletion of your data
- Opt-out of analytics tracking
- Export your settings and preferences

5. Children's Privacy
Mini Music is not intended for children under 13. We do not knowingly collect personal information from children under 13.

6. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.

7. Contact Us
If you have questions about our privacy practices, please contact us at: support@minimusic.app

8. Data Retention
We retain your data for as long as your account is active. You can request deletion at any time through the app settings.''';

  static const String _termsOfServiceContentVi = '''Điều khoản dịch vụ

Cập nhật lần cuối: April 2024

1. Chấp nhận điều khoản
Bằng cách sử dụng Mini Music, bạn đồng ý tuân theo các Điều khoản Dịch vụ này. Nếu bạn không đồng ý, xin vui lòng không sử dụng dịch vụ.

2. Giấy phép sử dụng
Cho phép tải tạm thời một bản sao tài liệu (thông tin hoặc phần mềm) trên Mini Music cho mục đích xem cá nhân, không thương mại. Đây là cấp giấy phép, không phải chuyển quyền sở hữu, và bạn không được:
- Sửa đổi hoặc sao chép tài liệu
- Sử dụng tài liệu cho mục đích thương mại hoặc trình bày công khai
- Cố gắng giải mã hoặc bẻ khóa phần mềm trong Mini Music
- Gỡ bỏ bất kỳ chú thích bản quyền hoặc sở hữu trí tuệ nào
- Chuyển tài liệu cho người khác hoặc "nhân bản" trên máy chủ khác

3. Tuyên bố miễn trừ
Tài liệu trên Mini Music được cung cấp theo dạng 'nguyên trạng'. Mini Music không bảo đảm bất kỳ điều gì, bao gồm bảo đảm ngầm định về khả năng thương mại, phù hợp cho mục đích cụ thể, hoặc không vi phạm quyền sở hữu trí tuệ.

4. Giới hạn
Trong bất kỳ trường hợp nào, Mini Music hoặc nhà cung cấp không chịu trách nhiệm về bất kỳ thiệt hại nào (bao gồm mất dữ liệu hoặc lợi nhuận) phát sinh từ việc sử dụng hoặc không thể sử dụng tài liệu.

5. Độ chính xác tài liệu
Tài liệu trên Mini Music có thể bao gồm lỗi kỹ thuật, chính tả hoặc hình ảnh. Mini Music không bảo đảm rằng nội dung là chính xác, đầy đủ hoặc cập nhật.

6. Bản quyền tài liệu
Tài liệu trên Mini Music được bảo vệ bằng bản quyền và thương hiệu. Việc sao chép hoặc truyền tải mà không có sự cho phép bằng văn bản là bị cấm.

7. Giới hạn trách nhiệm
Mini Music không chịu trách nhiệm cho bất kỳ thiệt hại gián tiếp, ngẫu nhiên, đặc biệt, hệ quả hoặc trừng phạt phát sinh từ việc sử dụng dịch vụ.

8. Sửa đổi
Mini Music có thể chỉnh sửa các điều khoản này bất kỳ lúc nào mà không cần thông báo. Bằng cách sử dụng dịch vụ, bạn đồng ý tuân theo phiên bản hiện tại.''';

  static const String _termsOfServiceContentEn = '''Terms of Service

Last Updated: April 2024

1. Acceptance of Terms
By using Mini Music, you agree to be bound by these Terms of Service. If you do not agree to abide by the above, please do not use this service.

2. Use License
Permission is granted to temporarily download one copy of the materials (information or software) on Mini Music for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
- Modify or copy the materials
- Use the materials for any commercial purpose or for any public display
- Attempt to decompile or reverse engineer any software contained on Mini Music
- Remove any copyright or other proprietary notations from the materials
- Transfer the materials to another person or "mirror" the materials on any other server

3. Disclaimer
The materials on Mini Music are provided on an 'as is' basis. Mini Music makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

4. Limitations
In no event shall Mini Music or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Mini Music.

5. Accuracy of Materials
The materials appearing on Mini Music could include technical, typographical, or photographic errors. Mini Music does not warrant that any of the materials on its app are accurate, complete, or current.

6. Materials Copyright
The materials on Mini Music are protected by copyrights and trademarks. Reproduction or transmission of the materials, without express written consent, is prohibited.

7. Limitations on Liability
Mini Music shall not be held liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the materials or services.

8. Modifications
Mini Music may revise these terms of service for its app at any time without notice. By using this app, you are agreeing to be bound by the then current version of these terms.

9. Third-Party Services
This app uses YouTube for audio content. Your use of YouTube content is subject to YouTube's Terms of Service.

10. Cancellation
Mini Music offers free access to music content. We reserve the right to discontinue or modify our service at any time.

11. Governing Law
These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction where Mini Music operates.

12. Contact Information
For questions regarding these terms, please contact: support@minimusic.app''';
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
