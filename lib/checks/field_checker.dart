import 'package:my_app/checks/valid_char.dart';

const _prohibitedSymbolMistake = 'Поле содержит запрещенные символы';
const _lengthMistake = 'Требуется не менее 3 символов и не более 16';

String? checkField(String password){
  if (!isAscii(password)) return _prohibitedSymbolMistake;
  if (password.length > 15 || password.length < 4) return _lengthMistake;
  return null;
}