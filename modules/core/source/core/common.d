module core.common;

/// Interface which all disposable objects implement
interface IDisposable {
    void onDestroy();
}