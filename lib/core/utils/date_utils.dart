import 'package:intl/intl.dart';

String formatThingDate(DateTime dateTime) {
  return DateFormat.yMMMd().add_jm().format(dateTime.toLocal());
}
