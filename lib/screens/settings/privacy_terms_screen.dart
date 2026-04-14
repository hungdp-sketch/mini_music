import 'package:flutter/material.dart';
import '../../core/theme.dart';

const String privacyPolicyContent = '''Mini Music Privacy Policy

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

const String termsOfServiceContent = '''Terms of Service

Last Updated: April 2024

1. Acceptance of Terms
By using Mini Music, you agree to be bound by these Terms of Service. If you do not agree to abide by the above, please do not use this service.

2. Use License
Permission is granted to temporarily download one copy of the materials (information or software) on Mini Music for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
- Modify or copy the materials
- Using the materials for any commercial purpose or for any public display
- Attempting to decompile or reverse engineer any software contained on Mini Music
- Removing any copyright or other proprietary notations from the materials
- Transferring the materials to another person or "mirroring" the materials on any other server

3. Disclaimer
The materials on Mini Music are provided on an 'as is' basis. Mini Music makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

4. Limitations
In no event shall Mini Music or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Mini Music.

5. Accuracy of Materials
The materials appearing on Mini Music could include technical, typographical, or photographic errors. Mini Music does not warrant that any of the materials on its website are accurate, complete, or current.

6. Materials Copyright
The materials on Mini Music are protected by copyrights and trademarks. Reproduction or transmission of the materials, without express written consent, is prohibited.

7. Limitations on Liability
Mini Music shall not be held liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the materials or services.

8. Modifications
Mini Music may revise these terms of service for its website at any time without notice. By using this website, you are agreeing to be bound by the then current version of these terms of service.

9. Third-Party Services
This app uses YouTube for audio content. Your use of YouTube content is subject to YouTube's Terms of Service.

10. Cancellation
Mini Music offers free access to music content. We reserve the right to discontinue or modify our service at any time.

11. Governing Law
These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction where Mini Music operates.

12. Contact Information
For questions regarding these terms, please contact: support@minimusic.app''';

class PrivacyTermsScreen extends StatelessWidget {
  final String title;
  final String content;

  const PrivacyTermsScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text(
              content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
