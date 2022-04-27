import 'package:my_app/checks/valid_char.dart';

const _prohibitedSymbolMistake = 'Поле содержит запрещенные символы';
const _lengthMistake = 'Поле должен состоять из более чем 3 символов и меньше 16';

String? checkField(String password){
  if (!isAscii(password)) return _prohibitedSymbolMistake;
  if (password.length > 15 || password.length < 4) return _lengthMistake;
  return null;
}