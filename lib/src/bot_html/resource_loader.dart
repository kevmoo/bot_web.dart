part of bot_html;

// TODO: error events?
abstract class ResourceLoader<T> {
  static const String StateUnloaded = 'unloaded';
  static const String StateLoading = 'loading';
  static const String StateLoaded = 'loaded';
  static const String StateError = 'error';

  static const int _defaultSize = 2000;

  final UnmodifiableListView<_ResourceEntry<T>> _entries;
  final StreamController _loadedEvent= new StreamController();
  final StreamController _progressEvent = new StreamController();

  String _state = StateUnloaded;

  ResourceLoader(Iterable<String> urlList)
      : _entries = new UnmodifiableListView(
          urlList.map((url) => new _ResourceEntry(url)).toList());

  int get completedCount => $(_entries).count((e) => e.completed);

  String get state => _state;

  Stream get loaded => _loadedEvent.stream;

  Stream get progress => _progressEvent.stream;

  T getResource(String url) => _getByUrl(url).resource;

  int get completedBytes {
    return $(_entries).selectNumbers((e) => e.completedBytes).sum();
  }

  int get totalBytes {
    return $(_entries).selectNumbers((e) {
      if(e.totalBytes == null) {
        return _defaultSize;
      } else {
        return e.totalBytes;
      }
    }).sum();
  }

  Future load() {
    assert(_state == StateUnloaded);
    _state = StateLoading;
    return Future.wait(_entries.map((e) => _httpLoad(e)))
        .then((_) {
          if(_entries.every((e) => e.completed)) {
            _state = StateLoaded;
            _loadedEvent.add(EMPTY_EVENT);
          }
        });
  }

  @protected
  Future<T> _doLoad(String blobUrl);

  _ResourceEntry<T> _getByUrl(String url) {
    assert(url != null);
    return _entries.singleWhere((e) => e.url == url);
  }

  _ResourceEntry<T> _getByBlobUrl(String blobUrl) {
    assert(blobUrl != null);
    return _entries.singleWhere((e) => e.matchesBlobUrl(blobUrl));
  }

  Future _httpLoad(_ResourceEntry<T> entry) {
    return HttpRequest.request(entry.url, responseType: 'blob',
        onProgress: (ProgressEvent args) => _onProgress(entry, args))
        .then((HttpRequest request) => _onLoadEnd(entry, request))
        .catchError((dynamic error) => _onError(entry, error));
  }

  Future _onLoadEnd(_ResourceEntry<T> entry, HttpRequest request) {
    assert(request.readyState == HttpRequest.DONE);
    assert(request.status == 200);
    require(request.response != null, 'request.response should not be null');
    final blobUrl = entry.getBlobUrl(request.response);

    return _doLoad(blobUrl)
        .then((T resource) {
          assert(_state == StateLoading);
          assert(resource != null);
          entry.setResource(resource);
        })
        .whenComplete(() => entry.revokeBlobUrl());
  }

  void _onError(_ResourceEntry<T> entry, dynamic error) {
    _libLogger.severe('There was an error loading resource ${entry.url}');
    _libLogger.severe(error.toString());
    throw error;
  }

  void _onProgress(_ResourceEntry<T> entry, ProgressEvent args) {
    assert(args.type == 'progress');
    assert(args.lengthComputable);

    if(entry.updateProgress(args.loaded, args.total)) {
      _progressEvent.add(EMPTY_EVENT);
    }
  }
}
