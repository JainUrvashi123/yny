import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    final scaffoldBgColor = isDark 
        ? AppConstants.backgroundColor 
        : const Color(0xFFE1E6EB);

    final cardBgColor = isDark 
        ? AppConstants.surfaceColor 
        : Colors.white;

    final textColor = isDark ? Colors.white70 : Colors.black87;
    final headerColor = isDark ? Colors.white : const Color(0xFF0F3F70);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.spaceMD, top: 8),
          child: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F3F70),
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: cardBgColor,
              side: BorderSide(
                color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Terms & Conditions',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: headerColor,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.spaceLG),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceLG),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yny Fine Jewels Terms and Conditions',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMD),
                _buildParagraph('Yny Fine Jewels does trading as Yny Fine Jewels in the USA.'),
                _buildParagraph('Yny Fine Jewels has and operates this website. The contact address for communication is listed on the contact us page of our website.'),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),

                _buildSectionTitle('Terms and conditions', accentColor),
                _buildParagraph(
                  'These terms and conditions administrate your access to our website. '
                  'Access means the interface, browsing, analysis, discussing, screening, sharing, posting, and downloading and or the ordering of products offered for sale on our website. '
                  'By using our website, you accept these terms and conditions in full. '
                  'If you disagree with these terms and conditions, you must not use our website or put an order on our website.'
                ),

                _buildSectionTitle('Disclaimer', accentColor),
                _buildParagraph(
                  'Information collected on our website has been gathered from many different associations. '
                  'Some articles are contradictory. Our work in finding this information was very broad and because of the multiple origins, '
                  'we cannot, therefore, be responsible for any mistakes, rectifications, reports, advice, of any article.'
                ),

                _buildSectionTitle('Liability', accentColor),
                _buildParagraph(
                  'Neither Yny Fine Jewels, nor any original provider of the objects, accept any liability for any direct, indirect, '
                  'incidental, or momentous loss of business profits or special damages arising from its publication, '
                  'availability, sale or offer for purchase from Yny Fine Jewels'
                ),

                _buildSectionTitle('Limitation of liability', accentColor),
                _buildParagraph(
                  'You expressly understand and agree that Yny Fine Jewels shall not be liable for any direct, indirect, '
                  'incidental, special, consequential or exemplary damages, including but not limited to, damages for loss of profits, '
                  'goodwill, use, data or other intangible losses resulting from the cost of procurement of substitute goods and services '
                  'resulting from any goods, data, information or services purchased or obtained or messages received or transactions entered '
                  'into through or from Yny Fine Jewels'
                ),

                _buildSectionTitle('Indemnity', accentColor),
                _buildParagraph(
                  'You agree to indemnify and hold Yny Fine Jewels, and its contributory, affiliate, suppliers, officers, '
                  'agents, representatives or other partners, and employees, harmless from any claim or demand, including '
                  'reasonable attorneys\' fees, made by any third party due to or arising out of any communication or transaction '
                  'with Yny Fine Jewels'
                ),
                const SizedBox(height: 8),
                Text(
                  'You expressly understand and agree that:',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Your use of our website is at your sole risk. The content of our website is provided on an as-is and as available basis. Yny Fine Jewels makes no promises or guarantees that our website will be available at all times.', textColor),
                _buildBulletPoint('Any material downloaded or otherwise obtained through the use of our website is done at your discretion and risk and that you will be solely responsible for any damage to your computer system or loss of data that results from the download of any such material.', textColor),

                _buildSectionTitle('Copyright', accentColor),
                _buildParagraph(
                  'All the material contained on the Yny Fine Jewels website is copyright. '
                  'No part of any page or any graphic from the Yny Fine Jewels website may be copied, reproduced, transmitted, '
                  'or distributed without the express written permission of Yny Fine Jewels'
                ),
                _buildParagraph('If you require any further information on permitted use, or a license to republish any material, please contact us at the address on of the page Yny Fine Jewels'),
                _buildParagraph('If you are granted a license to reproduce material you will be required to follow some simple guidelines about the way the information is displayed.'),
                _buildParagraph('An acknowledgment of the source must be included whenever copyright material is copied or published.'),

                _buildSectionTitle('Privacy policy', accentColor),
                _buildParagraph(
                  'Yny Fine Jewels Operates a very strict privacy policy to protect your visit to our website. '
                  'Please read our privacy policy regarding your visit to our website.'
                ),
                const SizedBox(height: AppConstants.spaceMD),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spaceLG, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
