import 'package:intl/intl.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _brlShort = NumberFormat.currency(
    locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

String money(double v) => _brl.format(v);
String moneyShort(double v) => _brlShort.format(v);
