import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/courses/domain/entities/live_session.dart';

abstract class CourseLiveSessionsState extends Equatable {
  const CourseLiveSessionsState();

  @override
  List<Object?> get props => [];
}

class CourseLiveSessionsInitial extends CourseLiveSessionsState {}

class CourseLiveSessionsLoading extends CourseLiveSessionsState {}

class CourseLiveSessionsLoaded extends CourseLiveSessionsState {
  final List<LiveSession> sessions;

  const CourseLiveSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class CourseLiveSessionsError extends CourseLiveSessionsState {
  final String message;

  const CourseLiveSessionsError(this.message);

  @override
  List<Object?> get props => [message];
}
