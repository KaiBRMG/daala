/// Debug flags to force each global screen state (DESIGN.md §3: "a debug
/// flag can force each state"). Flip in source while developing.
abstract final class DebugFlags {
  static const bool forceError = false;
  static const bool forceEmpty = false;

  static void maybeThrow() {
    if (forceError) {
      throw StateError('DebugFlags.forceError is enabled');
    }
  }

  static List<T> maybeEmpty<T>(List<T> value) =>
      forceEmpty ? <T>[] : value;
}
