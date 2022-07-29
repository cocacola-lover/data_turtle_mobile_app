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

class TagMapFields{
  static const id = "_id";
  static const tagName = "tag";
  static const groupName = "groupName";
}

class ParserMistake{
  static const tagParserException = "TagParser failed";
}

class FoodProductMapFields{
  // rateFields:
  static const rateUserField = "user";
  static const rateRateField = "rate";
  static const rateCommentField = "comment";
  // FoodProductsFields:
  static const foodProductNameField = "name";
  static const foodProductRateField = "rate";
  static const foodProductTagsField = "tags";
  static const foodProductIdField = "_id";
}

class ItemPanelStrings{
  static const yourRating = "Ваша оценка: ";
  static const averageRating = "Ср. оценка: ";

  static const yourComment = "Ваш комментарий: ";
  static const randomComment = "Случ. комментарий: ";
}

class ConnectionProblems {
  static const connectionLost = "Похоже вы отключены от сети. Подключитесь и попробуйте ещё раз";
  static const connectionFound = "Соединение было восстановлено";
}

class AppLines {
  static const name = "Turtle Data App";
}

class ActionPageLines{
  static const createNewPageName = "Создание записи";
  static const editOldPageName = "Редактирование записи";
  static const nameField = "Название";
  static const tagsField = "Теги";
  static const rateField = "Оценка";
  static const commentField = "Коммент";

  static const productAlreadyExists = "Такой продукт уже существует";
  static const somethingWentWrong = "Что-то пошло не так";
}

class TestUser{
  static const name = "TestUser";
  static const hexString = "6241dd3232adfc92ac741178";
}

class Routes{
  static const searchPage = "/search_page";
  static const logIn = '/log_in';
  static const signIn = '/sign_in';
  static const actionPage = '/action_page';
  static const settingPage = '/settings_page';
  static const loadingPage = '/loading_page';
  static const changePage = '/change_page';
}