String formatPrice(double price) {
  const double crore = 10000000;
  const double lakh = 100000;
  const double thousand = 1000;

  String format(double value, String suffix) {
    return '${value.toStringAsFixed(value >= 10 ? 1 : 2)} $suffix';
  }

  if (price.isNaN || price.isInfinite) return '0';

  final absPrice = price.abs();
  final sign = price < 0 ? '-' : '';

  if (absPrice >= crore) {
    return '$sign${format(absPrice / crore, 'Cr')}';
  } else if (absPrice >= lakh) {
    return '$sign${format(absPrice / lakh, 'L')}';
  } else if (absPrice >= thousand) {
    return '$sign${format(absPrice / thousand, 'K')}';
  } else {
    return '$sign${absPrice.toStringAsFixed(0)}';
  }
}