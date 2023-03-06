import 'dart:math';

humanReadableByte(int bytes) {
  const unit = 1000;
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  double n = bytes.toDouble();
  int i = 0;
  while (n >= unit) {
    n = n / unit;
    i++;
  }

  if (n < 10) {
    return "${n.toStringAsFixed(2)} ${units[i]}";
  } else {
    return "${n.toStringAsFixed(1)} ${units[i]}";
  }
}

///  漂亮的字节格式
prettyBytes(double bytes) {
  if (bytes == 0) {
    return "0 B";
  }

  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  final int exponent =
      min((log(bytes.abs()) / log(1000)).floor(), units.length - 1);
  bytes /= pow(1000, exponent);

  final String numberString =
      bytes % 1 == 0 ? bytes.toStringAsFixed(0) : bytes.toStringAsPrecision(3);
  return '$numberString ${units[exponent]}';
}

///  漂亮的时间格式
prettySeconds(int seconds) {
  String result = '';
  final int hours = seconds ~/ 3600;
  if (hours > 0) {
    result += '${hours}h';
  }

  final int minutes = (seconds % 3600) ~/ 60;
  if (minutes > 0) {
    result += '${minutes}m';
  }

  seconds = seconds % 60;
  if (seconds > 0) {
    result += '${seconds}s';
  }

  return result;
}
