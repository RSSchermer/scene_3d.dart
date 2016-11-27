part of rendering.realtime.bagl;

class ProgramPool {
  final Map<String, Program> _codePrograms = {};

  final Map<Program, int> _programReferenceCounts = {};

  Program acquire(String vertexShaderSource, String fragmentShaderSource) {
    final code = vertexShaderSource + fragmentShaderSource;
    var program = _codePrograms[code];

    if (program == null) {
      program = new Program(vertexShaderSource, fragmentShaderSource);
      _codePrograms[code] = program;
    }

    return program;
  }

  void release(Program program) {
    if ((_programReferenceCounts[program] ?? 0) > 1) {
      _programReferenceCounts[program]--;
    } else if (program != null) {
      _programReferenceCounts.remove(program);
      _codePrograms
          .remove(program.vertexShaderSource + program.fragmentShaderSource);
    }
  }
}
