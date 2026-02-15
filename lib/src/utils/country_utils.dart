class CountryUtils {
  static const Map<String, String> _flags = {
    'United States': '🇺🇸',
    'US': '🇺🇸',
    'USA': '🇺🇸',
    'China': '🇨🇳',
    'CN': '🇨🇳',
    'Canada': '🇨🇦',
    'United Kingdom': '🇬🇧',
    'Australia': '🇦🇺',
    'New Zealand': '🇳🇿',
    'Taiwan': '🇹🇼',
    'Hong Kong': '🇭🇰',
    'South Korea': '🇰🇷',
    'Singapore': '🇸🇬',
    'Japan': '🇯🇵',
    'Philippines': '🇵🇭',
    'Malaysia': '🇲🇾',
    'Thailand': '🇹🇭',
    'Vietnam': '🇻🇳',
    'Indonesia': '🇮🇩',
    'Mexico': '🇲🇽',
    'Colombia': '🇨🇴',
    'Puerto Rico': '🇵🇷',
    'Chile': '🇨🇱',
    'Brazil': '🇧🇷',
    'Germany': '🇩🇪',
    'Spain': '🇪🇸',
    'France': '🇫🇷',
    'Ireland': '🇮🇪',
    'Finland': '🇫🇮',
    'Turkey': '🇹🇷',
    'Kazakhstan': '🇰🇿',
    'Bahrain': '🇧🇭',
    'Ethiopia': '🇪🇹',
    'Morocco': '🇲🇦',
    'Rwanda': '🇷🇼',
    'Tunisia': '🇹🇳',
    'Uganda': '🇺🇬',
    'Andorra': '🇦🇩',
    'Austria': '🇦🇹',
    'Azerbaijan': '🇦🇿',
    'Belgium': '🇧🇪',
    'Switzerland': '🇨🇭',
    'Czech Republic': '🇨🇿',
    'Estonia': '🇪🇪',
    'Luxembourg': '🇱🇺',
    'Slovakia': '🇸🇰',
    'Saudi Arabia': '🇸🇦',
    'Paraguay': '🇵🇾',
    'Panama': '🇵🇦',
    'Macau': '🇲🇴',
    'Russia': '🇷🇺',
  };

  static String getFlagEmoji(String? countryName) {
    if (countryName == null || countryName.isEmpty) {
      return '🌐'; // Fallback globe
    }

    final cleaned = countryName.trim();

    // Exact match
    if (_flags.containsKey(cleaned)) {
      return _flags[cleaned]!;
    }

    // Case insensitive match
    for (final key in _flags.keys) {
      if (key.toLowerCase() == cleaned.toLowerCase()) {
        return _flags[key]!;
      }
    }

    // Try partial/fuzzy match if needed, or specific remapping
    if (cleaned.contains('United States')) return '🇺🇸';
    if (cleaned.contains('China')) return '🇨🇳';

    return '🌐'; // Default backup
  }
}
