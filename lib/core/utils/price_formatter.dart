/// Price formatting and rounding utility to keep price display consistent
/// and clean across all screens and screen sizes.
class PriceFormatter {
  /// Parses any dynamic / string / num price value safely to double.
  static double parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final cleanStr = value.toString().replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(cleanStr) ?? 0.0;
  }

  /// Rounds off a price to whole number and formats it with commas: e.g. "$1,234"
  static String formatRoundPrice(dynamic value, {String symbol = '\$'}) {
    final double amount = parsePrice(value);
    final int rounded = amount.round();
    final formattedNum = rounded.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$symbol$formattedNum';
  }

  /// Formats rounded number without symbol: e.g. "1,234"
  static String formatNumber(dynamic value) {
    final double amount = parsePrice(value);
    final int rounded = amount.round();
    return rounded.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
