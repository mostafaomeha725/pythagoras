import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/download_resource_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/download_resource/download_resource_state.dart';

class DownloadResourceCubit extends Cubit<DownloadResourceState> {
  final DownloadResourceUseCase downloadResourceUseCase;

  DownloadResourceCubit({required this.downloadResourceUseCase}) : super(DownloadResourceInitial());

  Future<void> downloadResource({
    required int resourceId,
    required String title,
    required String fileName,
  }) async {
    emit(DownloadResourceLoading());
    final result = await downloadResourceUseCase(resourceId: resourceId, title: title, fileName: fileName);
    result.fold(
      (failure) => emit(DownloadResourceError(failure.message)),
      (_) => emit(DownloadResourceSuccess()),
    );
  }
}
