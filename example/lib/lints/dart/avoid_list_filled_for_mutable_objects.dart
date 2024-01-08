// ignore_for_file: public_member_api_docs, sort_constructors_first
class _ConstantClass {
  const _ConstantClass();
}

class _MutableClass {
  double x;

  _MutableClass({
    required this.x,
  });

  void temp() {
    x = 2;
  }
}

void main() {
  final mutableObject = _MutableClass(x: 1);

  // ignore: unused_local_variable
  final literalConstantsList = List.filled(10, true);
  // ignore: unused_local_variable
  final constantObjectsList = List.filled(10, const _ConstantClass());

  // expect_lint: prefer_list_generate_for_mutable_objects
  final list = List.filled(1, mutableObject);
  list.first;
}
