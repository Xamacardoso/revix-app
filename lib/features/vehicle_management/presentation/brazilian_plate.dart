import 'package:flutter/services.dart';

String normalizeBrazilianPlate(String value) =>
    value.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');

bool isBrazilianPlateValid(String value) {
  if (value.trim().isEmpty) return true;
  final plate = normalizeBrazilianPlate(value);
  return RegExp(r'^[A-Z]{3}[0-9]{4}$').hasMatch(plate) ||
      RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$').hasMatch(plate);
}

String formatBrazilianPlate(String value) {
  final normalized = normalizeBrazilianPlate(value);
  final plate = normalized.substring(0, normalized.length.clamp(0, 7).toInt());
  if (plate.length >= 5 && RegExp(r'^[A-Z]{3}[0-9]{2}').hasMatch(plate)) {
    return '${plate.substring(0, 3)}-${plate.substring(3)}';
  }
  return plate;
}

class BrazilianPlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatBrazilianPlate(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
