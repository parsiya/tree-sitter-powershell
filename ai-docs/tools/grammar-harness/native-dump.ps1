# Persistent native PowerShell parse dumper. Parse only; nothing is executed.
# Each stdin line is "<comma-separated byte offsets>\t<path>". Each stdout line
# is JSON with parse errors and the spans of commands, command elements and
# redirections, in UTF-8 byte offsets after a skipped UTF-8 BOM. For each
# requested offset, "at" gives the innermost native node path containing it.
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation.Language;
using System.Text;
using System.Text.Json;

public static class NativeDump {
  static int[] ByteMap(string s) {
    var map = new int[s.Length + 1];
    int b = 0;
    for (int i = 0; i < s.Length; i++) {
      map[i] = b;
      char c = s[i];
      if (char.IsHighSurrogate(c) && i + 1 < s.Length && char.IsLowSurrogate(s[i + 1])) {
        map[i + 1] = b;
        b += 4;
        i++;
      } else {
        b += c < 0x80 ? 1 : c < 0x800 ? 2 : 3;
      }
    }
    map[s.Length] = b;
    return map;
  }

  static string Q(string s) { return JsonSerializer.Serialize(s); }

  public static string Dump(string path, int[] offsets) {
    byte[] bytes = File.ReadAllBytes(path);
    int skip = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF ? 3 : 0;
    string text;
    try {
      text = new UTF8Encoding(false, true).GetString(bytes, skip, bytes.Length - skip);
    } catch (DecoderFallbackException) {
      return "{\"st\":\"non_utf8\"}";
    }
    Token[] tokens;
    ParseError[] errors;
    var ast = Parser.ParseInput(text, out tokens, out errors);
    var map = ByteMap(text);
    Func<IScriptExtent, int> S = e => map[e.StartOffset];
    Func<IScriptExtent, int> E = e => map[e.EndOffset];
    var sb = new StringBuilder("{\"st\":\"ok\",\"err\":[");
    sb.Append(string.Join(",", errors.Take(20).Select(x =>
      "{\"id\":" + Q(x.ErrorId) + ",\"s\":" + S(x.Extent) + ",\"r\":" + x.Extent.StartLineNumber + "}")));
    sb.Append("],\"cmd\":[");
    var commands = new List<string>();
    foreach (CommandAst c in ast.FindAll(n => n is CommandAst, true)) {
      var elements = new List<string>();
      bool stop = false;
      foreach (var e in c.CommandElements.Skip(1)) {
        if (e.Extent.Text.StartsWith("--%")) { stop = true; continue; }
        elements.Add("[" + S(e.Extent) + "," + E(e.Extent) + "," + Q(e.GetType().Name) + "]");
        var p = e as CommandParameterAst;
        if (p != null && p.Argument != null)
          elements.Add("[" + S(p.Argument.Extent) + "," + E(p.Argument.Extent) + "," + Q(p.Argument.GetType().Name) + "]");
      }
      commands.Add("{\"s\":" + S(c.Extent) + ",\"e\":" + E(c.Extent) + ",\"sp\":" + (stop ? 1 : 0) +
        ",\"el\":[" + string.Join(",", elements) + "]}");
    }
    sb.Append(string.Join(",", commands));
    sb.Append("],\"rd\":[");
    sb.Append(string.Join(",", ast.FindAll(n => n is RedirectionAst, true)
      .Select(r => "[" + S(r.Extent) + "," + E(r.Extent) + "]")));
    sb.Append("],\"at\":[");
    var at = new List<string>();
    foreach (int o in offsets) {
      Ast inner = null;
      foreach (var n in ast.FindAll(n => S(n.Extent) <= o && o < Math.Max(E(n.Extent), S(n.Extent) + 1), true))
        if (inner == null || E(n.Extent) - S(n.Extent) <= E(inner.Extent) - S(inner.Extent)) inner = n;
      var names = new List<string>();
      for (var n = inner; n != null && names.Count < 4; n = n.Parent) names.Insert(0, n.GetType().Name);
      at.Add("{\"o\":" + o + ",\"path\":" + Q(string.Join(">", names)) + "}");
    }
    sb.Append(string.Join(",", at));
    sb.Append("]}");
    return sb.ToString();
  }
}
'@
while ($null -ne ($line = [Console]::In.ReadLine())) {
  $tab = $line.IndexOf("`t")
  $offsets = [int[]]::new(0)
  if ($tab -gt 0) { $offsets = [int[]]($line.Substring(0, $tab).Split(',')) }
  $path = $line.Substring($tab + 1)
  try {
    $out = [NativeDump]::Dump($path, $offsets)
  } catch {
    $out = '{"st":"exception","msg":' + (ConvertTo-Json -Compress $_.Exception.Message) + '}'
  }
  [Console]::Out.WriteLine($out)
  [Console]::Out.Flush()
}
