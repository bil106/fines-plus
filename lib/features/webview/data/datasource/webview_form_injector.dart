// ignore_for_file: unnecessary_brace_in_string_interps

class WebViewFormInjector {
  static String escapeForJs(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAll('\r', r'\r');

  static String buildFillAndSubmitJs(Map<String, String> values) {
    final sb = StringBuffer();
    sb.writeln("(function(){");

    values.forEach((name, value) {
      final v = escapeForJs(value);
      sb.writeln("""
        (function(){
          var el = document.querySelector('[name="${name}"]') || document.getElementById('${name}');
          if (el) {
            var t = (el.type || '').toLowerCase();
            if (t === 'checkbox' || t === 'radio') {
              el.checked = ${v == '1' || v.toLowerCase() == 'true' ? 'true' : 'false'};
              el.dispatchEvent(new Event('change', {bubbles:true}));
            } else {
              el.value = '${v}';
              el.dispatchEvent(new Event('input', {bubbles:true}));
              el.dispatchEvent(new Event('change', {bubbles:true}));
            }
          }
        })();
      """);
    });

    sb.writeln("})();");
    return sb.toString();
  }
}
