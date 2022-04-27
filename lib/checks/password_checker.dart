import 'field_checker.dart';

const _roma = 'Roma';
const _best = 'best';
const _noRomaMistake = 'Пароль должен содержать хотя бы одно слово "$_roma" внутри';
const _noBestMistake = 'Пароль должен содержать хотя бы одно слово "$_best" внутри';
const _numberOfTries = 3;


class PasswordChecker{
  int tries = 0;

  PasswordChecker();
  String? check(String password){
      String? check = checkField(password);
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