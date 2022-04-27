class Wrapper<T> {
  T value;
  Wrapper(this.value);

  @override
  bool operator==(other) =>
    (other is T && (value == other)) || (other is Wrapper<T> && value == other.value);

}