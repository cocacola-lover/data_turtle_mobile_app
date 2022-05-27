class FieldMistakes{
  static const prohibitedSymbolMistake = 'Поле содержит запрещенные символы';
  static const lengthMistake = 'Требуется не менее 3 символов и не более 16';
}

class LogInMistakes{
  static const userDoesNotExist = "Пользователя не существует";
  static const wrongPassword = "Не верный пароль";
}

class SignInMistakes{
  static const passwordsAreNotSame = "Пароли должны совпадать";
  static const tooManyUsers = "К сожалению, лимит пользователей был достигнут";
}

class OtherMistakes{
  static const unthinkableMessage = "Something went really wrong here";
  static const somethingWentWrong = "Что-то пошло не так";
}

class ConnectionString{
  static const url = "mongodb+srv://Admin:2xxRHKviEsp6AKq@cluster0.gdgrc.mongodb.net/app_files?retryWrites=true&w=majority";
  static const fakeUrl = "mongodb+srv://Admin:2yxRHKviEsp6AKq@cluster1.gdgrc.mongodb.net/app_files?retryWrites=true&w=majority";
}