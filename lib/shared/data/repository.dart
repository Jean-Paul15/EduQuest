/// Base contract shared by all repositories in the Clean Architecture layer.
/// §11.1: Every repository extends or implements this base.
abstract class Repository {
  const Repository();

  /// Optional lifecycle hook called when the app is about to dispose.
  Future<void> dispose() async {}
}
