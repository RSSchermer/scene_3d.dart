part of shape.loading.obj;

class _ChunkedAttributeData {
  final int rowLength;

  final int chunkLength;

  final List<AttributeDataTable> _filledChunks = [];

  AttributeDataTable _activeChunk;

  int _activeChunkFillCount = 0;

  _ChunkedAttributeData(this.rowLength, this.chunkLength);

  int get rowCount =>
      _filledChunks.length * chunkLength + _activeChunkFillCount;

  void addRow(List<double> values) {
    _activeChunk ??= new AttributeDataTable(rowLength, chunkLength);

    if (_activeChunkFillCount == chunkLength) {
      _filledChunks.add(_activeChunk);
      _activeChunk = new AttributeDataTable(rowLength, chunkLength);
      _activeChunkFillCount = 0;
    }

    final currentRow = _activeChunk[_activeChunkFillCount];

    for (var i = 0; i < rowLength && i < values.length; i++) {
      currentRow[i] = values[i];
    }

    _activeChunkFillCount++;
  }

  AttributeDataRowView rowAt(int index) {
    final chunkIndex = index ~/ chunkLength;
    final rowIndex = index.remainder(chunkLength);

    var chunk;

    if (chunkIndex < _filledChunks.length) {
      chunk = _filledChunks[chunkIndex];
    } else if (chunkIndex == _filledChunks.length) {
      chunk = _activeChunk;
    }

    if (chunk != null) {
      return chunk[rowIndex];
    } else {
      return null;
    }
  }

  AttributeDataTable asAttributeDataTable() {
    final storage = new Float32List(rowCount * rowLength);
    final chunkSize = chunkLength * rowLength;

    for (var i = 0; i < _filledChunks.length; i++) {
      final data = new Float32List.view(_filledChunks[i].buffer);
      final start = i * chunkSize;

      storage.setRange(start, start + chunkSize, data);
    }

    if (_activeChunk != null) {
      final data = new Float32List.view(_activeChunk.buffer);
      final start = _filledChunks.length * chunkSize;

      storage.setRange(start, start + _activeChunkFillCount * rowLength, data);
    }

    return new AttributeDataTable.view(rowLength, storage.buffer);
  }
}
