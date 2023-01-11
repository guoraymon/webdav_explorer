humanReadableByte(int bytes) {
  const unit = 1000;
  const units = ['bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  double n = bytes.toDouble();
  int i = 0;
  while (n >= unit) {
    n = n / unit;
    i++;
  }

  return "${n.toStringAsFixed(1)} ${units[i]}";
}
