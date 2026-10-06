abstract class DownloadResourceState {}

class DownloadResourceInitial extends DownloadResourceState {}
class DownloadResourceLoading extends DownloadResourceState {}
class DownloadResourceSuccess extends DownloadResourceState {}
class DownloadResourceError extends DownloadResourceState {
  final String message;
  DownloadResourceError(this.message);
}
