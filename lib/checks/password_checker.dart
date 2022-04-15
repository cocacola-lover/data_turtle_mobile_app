import 'package:my_app/checks/valid_char.dart';

const _lengthMistake = 'Пароль должен состоять из более чем 3 символов и меньше 16';
const _roma = 'Roma';
const _best = 'best';
const _noRomaMistake = 'Пароль должен содержать хотя бы одно слово "$_roma" внутри';
const _noBestMistake = 'Пароль должен содержать хотя бы одно слово "$_best" внутри';
const _prohibitedSymbolMistake = 'Пароль содержит запрещенные символы';
const _numberOfTries = 3;


String? checkPassword(String password){
  if (!isAscii(password)) return _prohibitedSymbolMistake;
  if (password.length > 15 || password.length < 4) return _lengthMistake;
  return null;
}

class PasswordChecker{
  int tries = 0;

  PasswordChecker();
  String? check(String password){
      String? check = checkPassword(password);
      if (check != null) return check;
      if (tries < _numberOfTries){
        if (!password.contains(_roma)){
          tries++;
          return _noRomaMistake;
        }
        if (!password.contains(_best)){
          tries++;
          return _noBestMistake;
        }
        return null;
      }
      return null;
  }
}