/// Group an integer with a narrow no-break space every three digits, matching
/// the prototype's `Number.toLocaleString('fr-FR')` output (e.g. 1847 → "1 847").
String groupThousands(num value) {
  final n = value.round();
  final neg = n < 0;
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) {
      buf.write(' '); // narrow no-break space
    }
    buf.write(digits[i]);
  }
  return neg ? '-$buf' : buf.toString();
}

/// "2 500 F" style price.
String fcfaShort(num value) => '${groupThousands(value)} F';
