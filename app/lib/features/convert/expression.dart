/// Tiny expression evaluator for amount fields: + - * / and parentheses.
/// Numbers may use `.` or `,` as decimal separator. Whitespace is ignored.
double? tryEvaluateExpression(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Plain number (no operators); still normalize comma.
  if (!_hasOperator(trimmed)) {
    return _parseNumber(trimmed);
  }

  try {
    final tokens = _tokenize(_normalize(trimmed));
    final rpn = _toRpn(tokens);
    return _evalRpn(rpn);
  } catch (_) {
    return null;
  }
}

bool _hasOperator(String s) {
  // Allow leading +/- as sign on a plain number.
  final body = s.startsWith('+') || s.startsWith('-') ? s.substring(1) : s;
  return RegExp(r'[+\-*/()]').hasMatch(body);
}

String _normalize(String s) => s.replaceAll(',', '.').replaceAll(' ', '');

double? _parseNumber(String s) {
  final n = double.tryParse(s.replaceAll(',', '.').replaceAll(' ', ''));
  if (n == null || !n.isFinite) return null;
  return n;
}

enum _TokKind { number, op, lparen, rparen }

class _Tok {
  _Tok(this.kind, this.value);
  final _TokKind kind;
  final String value;
}

List<_Tok> _tokenize(String s) {
  final out = <_Tok>[];
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == '(') {
      out.add(_Tok(_TokKind.lparen, c));
      i++;
      continue;
    }
    if (c == ')') {
      out.add(_Tok(_TokKind.rparen, c));
      i++;
      continue;
    }
    if ('+-*/'.contains(c)) {
      // Unary + / - when at start or after operator / '('.
      final unary = out.isEmpty ||
          out.last.kind == _TokKind.op ||
          out.last.kind == _TokKind.lparen;
      if (unary && (c == '+' || c == '-')) {
        final start = i;
        i++;
        while (i < s.length && _isNumChar(s[i])) {
          i++;
        }
        if (i == start + 1) {
          throw FormatException('dangling unary');
        }
        out.add(_Tok(_TokKind.number, s.substring(start, i)));
        continue;
      }
      out.add(_Tok(_TokKind.op, c));
      i++;
      continue;
    }
    if (_isNumChar(c)) {
      final start = i;
      while (i < s.length && _isNumChar(s[i])) {
        i++;
      }
      out.add(_Tok(_TokKind.number, s.substring(start, i)));
      continue;
    }
    throw FormatException('bad char $c');
  }
  return out;
}

bool _isNumChar(String c) =>
    (c.compareTo('0') >= 0 && c.compareTo('9') <= 0) || c == '.';

int _prec(String op) => (op == '+' || op == '-') ? 1 : 2;

List<_Tok> _toRpn(List<_Tok> tokens) {
  final out = <_Tok>[];
  final ops = <_Tok>[];
  for (final t in tokens) {
    switch (t.kind) {
      case _TokKind.number:
        out.add(t);
      case _TokKind.op:
        while (ops.isNotEmpty &&
            ops.last.kind == _TokKind.op &&
            _prec(ops.last.value) >= _prec(t.value)) {
          out.add(ops.removeLast());
        }
        ops.add(t);
      case _TokKind.lparen:
        ops.add(t);
      case _TokKind.rparen:
        while (ops.isNotEmpty && ops.last.kind != _TokKind.lparen) {
          out.add(ops.removeLast());
        }
        if (ops.isEmpty) throw FormatException('mismatched )');
        ops.removeLast();
    }
  }
  while (ops.isNotEmpty) {
    final t = ops.removeLast();
    if (t.kind == _TokKind.lparen) throw FormatException('mismatched (');
    out.add(t);
  }
  return out;
}

double _evalRpn(List<_Tok> rpn) {
  final stack = <double>[];
  for (final t in rpn) {
    if (t.kind == _TokKind.number) {
      final n = double.tryParse(t.value);
      if (n == null) throw FormatException('bad number');
      stack.add(n);
      continue;
    }
    if (stack.length < 2) throw FormatException('arity');
    final b = stack.removeLast();
    final a = stack.removeLast();
    stack.add(switch (t.value) {
      '+' => a + b,
      '-' => a - b,
      '*' => a * b,
      '/' => b == 0 ? throw FormatException('div0') : a / b,
      _ => throw FormatException('op'),
    });
  }
  if (stack.length != 1) throw FormatException('stack');
  final v = stack.single;
  if (!v.isFinite) throw FormatException('nan');
  return v;
}
