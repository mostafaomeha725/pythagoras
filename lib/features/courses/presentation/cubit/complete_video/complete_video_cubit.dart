import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';

abstract class CompleteVideoState {}

class CompleteVideoInitial extends CompleteVideoState {}

class CompleteVideoLoading extends CompleteVideoState {
  final int videoId;
  CompleteVideoLoading(this.videoId);
}

class CompleteVideoSuccess extends CompleteVideoState {
  final int videoId;
  final String message;
  CompleteVideoSuccess({required this.videoId, required this.message});
}

class CompleteVideoError extends CompleteVideoState {
  final int videoId;
  final String message;
  CompleteVideoError({required this.videoId, required this.message});
}

class CompleteVideoCubit extends Cubit<CompleteVideoState> {
  final CoursesRepository repository;

  CompleteVideoCubit({required this.repository}) : super(CompleteVideoInitial());

  Future<void> completeVideo(int videoId) async {
    emit(CompleteVideoLoading(videoId));
    final result = await repository.completeVideo(videoId);
    result.fold(
      (failure) {
        if (!isClosed) emit(CompleteVideoError(videoId: videoId, message: failure.message));
      },
      (message) {
        if (!isClosed) emit(CompleteVideoSuccess(videoId: videoId, message: message));
      },
    );
  }
}
