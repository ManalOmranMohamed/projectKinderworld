bool isValidEmailFormat(String value) {
  final email = value.trim();
  if (email.isEmpty) return false;
  const pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  return RegExp(pattern).hasMatch(email);
}
