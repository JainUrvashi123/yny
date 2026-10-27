import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/diamond_model.dart';

class DiamondShareDialog extends StatefulWidget {
  final List<DiamondModel> diamonds;

  const DiamondShareDialog({Key? key, required this.diamonds}) : super(key: key);

  @override
  State<DiamondShareDialog> createState() => _DiamondShareDialogState();
}

class _DiamondShareDialogState extends State<DiamondShareDialog> {
  bool _shareImage = true;
  bool _shareVideo = true;
  bool _shareCert = true;

  bool _withPrice = true;
  bool _isGuest = false;

  final TextEditingController _rapMarkupController = TextEditingController();
  final TextEditingController _moneyMarkupController = TextEditingController();
  final TextEditingController _dollarMarkupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId == 'guest') {
      setState(() {
        _isGuest = true;
        _withPrice = false;
      });
    }
  }

  @override
  void dispose() {
    _rapMarkupController.dispose();
    _moneyMarkupController.dispose();
    _dollarMarkupController.dispose();
    super.dispose();
  }

  void _share() async {
    final buffer = StringBuffer();
    
    final bool withPrice = _isGuest ? false : _withPrice;
    
    double rapMarkup = double.tryParse(_rapMarkupController.text) ?? 0.0;
    double moneyMarkup = double.tryParse(_moneyMarkupController.text) ?? 0.0;
    double dollarMarkup = double.tryParse(_dollarMarkupController.text) ?? 0.0;

    for (var diamond in widget.diamonds) {
      buffer.writeln('Stock#: ${diamond.stockId ?? ""}');
      
      if (_shareImage && diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty) {
        buffer.writeln('Image ${diamond.diamondImage}');
      }
      if (_shareVideo && diamond.diamondVideo != null && diamond.diamondVideo!.isNotEmpty) {
        buffer.writeln('Video ${diamond.diamondVideo}');
      }
      if (_shareCert && diamond.reportFilename != null && diamond.reportFilename!.isNotEmpty) {
        buffer.writeln('Cert ${diamond.reportFilename}');
      }

      buffer.writeln('Natural Diamond');
      
      final specs = [
        diamond.shape,
        diamond.color,
        diamond.grade, // clarity
        diamond.cut,
        diamond.polish,
        diamond.symmetry,
        diamond.fluorescenceInt,
        diamond.lab,
        diamond.reportNo
      ].where((s) => s != null && s.isNotEmpty && s.toUpperCase() != 'NA').join('-');
      
      buffer.writeln(specs);

      if (withPrice) {
        double weight = double.tryParse(diamond.weight ?? "0") ?? 0.0;
        double discount = double.tryParse(diamond.newDiscount ?? "0") ?? 0.0;
        double costCarat = double.tryParse(diamond.costCarat ?? "0") ?? 0.0;
        double totalPrice = double.tryParse(diamond.totalPrice ?? "0") ?? 0.0;
        double rapnet = double.tryParse(diamond.rapnet ?? "0") ?? 0.0;

        // Fallback for rapnet if it is 0 but we can derive it
        if (rapnet == 0 && costCarat > 0 && discount != 0) {
          rapnet = costCarat / ((100 + discount) / 100);
        }
        if (rapnet == 0) {
          rapnet = costCarat;
        }

        // Apply markups
        if (rapMarkup != 0) {
           discount += rapMarkup;
           double originalMultiplier = (100 + discount - rapMarkup) / 100;
           if (originalMultiplier != 0) {
             double baseTotal = totalPrice / originalMultiplier;
             double newMultiplier = (100 + discount) / 100;
             totalPrice = baseTotal * newMultiplier;
             if (weight > 0) costCarat = totalPrice / weight;
           }
        }

        if (moneyMarkup != 0) {
          totalPrice = totalPrice * (1 + (moneyMarkup / 100));
          if (weight > 0) costCarat = totalPrice / weight;
        }

        if (dollarMarkup != 0) {
          totalPrice += dollarMarkup;
          if (weight > 0) costCarat = totalPrice / weight;
        }

        // Recalculate discount based on final costCarat and rapnet
        if ((moneyMarkup != 0 || dollarMarkup != 0) && rapnet > 0) {
          discount = ((costCarat / rapnet) - 1) * 100;
        }

        String formattedDiscount = "";
        if (discount != 0) {
          String sign = discount > 0 ? '+' : '';
          String numStr = discount.toStringAsFixed(2);
          if (numStr.endsWith('.00')) {
            numStr = numStr.substring(0, numStr.length - 3);
          } else if (numStr.endsWith('0') && numStr.contains('.')) {
            numStr = numStr.substring(0, numStr.length - 1);
          }
          formattedDiscount = "$sign$numStr% Off";
        }

        String priceLine = "${weight.toStringAsFixed(2)} Ct $formattedDiscount P/Ct \$${costCarat.toStringAsFixed(0)} Total \$${totalPrice.toStringAsFixed(0)}";
        // To precisely match format: "1.20 Ct -50% Off P/Ct $4650 Total $5580"
        priceLine = priceLine.replaceAll("  ", " ");
        buffer.writeln(priceLine);
      } else {
        double weight = double.tryParse(diamond.weight ?? "0") ?? 0.0;
        buffer.writeln("${weight.toStringAsFixed(2)} Ct");
      }
      
      buffer.writeln(''); // Empty line between diamonds
    }

    final text = buffer.toString().trim();
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final fallbackUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
        }
      }
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.blue[300] : const Color(0xFF0D47A1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('MEDIA', isDark),
              const Divider(),
              CheckboxListTile(
                title: const Text('Image'),
                value: _shareImage,
                onChanged: (v) => setState(() => _shareImage = v ?? true),
                activeColor: accentColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Video'),
                value: _shareVideo,
                onChanged: (v) => setState(() => _shareVideo = v ?? true),
                activeColor: accentColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Certificate'),
                value: _shareCert,
                onChanged: (v) => setState(() => _shareCert = v ?? true),
                activeColor: accentColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              const SizedBox(height: 10),
              
              if (!_isGuest) ...[
                _buildSectionTitle('DETAILS', isDark),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _withPrice = true),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _withPrice ? null : Colors.transparent,
                          side: BorderSide(color: _withPrice ? accentColor : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_withPrice) Icon(Icons.check, size: 16, color: accentColor),
                              if (_withPrice) const SizedBox(width: 4),
                              Text('With Price', style: TextStyle(color: _withPrice ? accentColor : Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _withPrice = false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_withPrice ? null : Colors.transparent,
                          side: BorderSide(color: !_withPrice ? accentColor : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_withPrice) Icon(Icons.check, size: 16, color: accentColor),
                              if (!_withPrice) const SizedBox(width: 4),
                              Text('Without Price', style: TextStyle(color: !_withPrice ? accentColor : Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildSectionTitle('MARKUP', isDark),
                const Divider(),
                const SizedBox(height: 10),
                
                Text('Natural Markup Rap %', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _rapMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: 'markup rap %',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text('Natural Markup % (Money Wise)', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _moneyMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: '% money wise',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text('Natural Markup \$ (Dollar Wise)', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _dollarMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: '\$ dollar wise',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _share,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
