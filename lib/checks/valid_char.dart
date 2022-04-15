bool isAscii(String str){
  bool ans = true;
  for (int i = 0; i < str.length; i++){
    if (str.codeUnitAt(i) < 33 || str.codeUnitAt(i) > 126) ans = false;
  }
  return ans;
}