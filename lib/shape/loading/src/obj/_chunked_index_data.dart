part of shape.loading.obj;

class _ChunkedIndexData {
  final int chunkLength;

  final List<Uint16List> _filledChunks = [];

  Uint16List _activeChunk;

  int _activeChunkFillCount = 0;

  _ChunkedIndexData(this.chunkLength);

  int get indexCount =>
      _filledChunks.length * chunkLength + _activeChunkFillCount;

  void add(int index) {
    _activeChunk ??= new Uint16List(chunkLength);

    if (_activeChunkFillCount == chunkLength) {
      _filledChunks.add(_activeChunk);
      _activeChunk = new Uint16List(chunkLength);
      _activeChunkFillCount = 0;
    }

    _activeChunk[_activeChunkFillCount] = index;
    _activeChunkFillCount++;
  }

  IndexList asIndexList() {
    final indexList = new IndexList(indexCount);

    for (var i = 0; i < _filledChunks.length; i++) {
      final start = i * chunkLength;

      indexList.setRange(start, start + chunkLength, _filledChunks[i]);
    }

    if (_activeChunk != null) {
      final start = _filledChunks.length * chunkLength;

      indexList.setRange(start, start + _activeChunkFillCount, _activeChunk);
    }

    return indexList;
  }
}
