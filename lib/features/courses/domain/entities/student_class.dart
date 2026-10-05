import 'package:equatable/equatable.dart';

class StudentClass extends Equatable {
  final int id;
  final String name;

  const StudentClass({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
