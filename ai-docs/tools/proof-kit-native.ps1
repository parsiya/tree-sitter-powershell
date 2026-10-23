# Native side of proof-kit.mjs. Parse only: Parser.ParseInput, nothing is evaluated.
#
# usage: pwsh -NoLogo -NoProfile -NonInteractive -File proof-kit-native.ps1 -ManifestPath FILE
#   FILE is a JSON array of {"name", "path"}. Output: one JSON line with the
#   PowerShell version, then one JSON line per case, in manifest order.
#
# Offsets are UTF-8 byte offsets in the file's original bytes. A UTF-8 BOM is
# not part of the script text (PowerShell's file reader drops it), so the text
# is decoded after the BOM and its offsets are shifted by 3; inputs that are not
# strict UTF-8 are reported as "non_utf8", never guessed.
# Per case: st ok|non_utf8|exception; bom; err [[id, s, e, message]];
# nodes [[kind, s, e, parent, extra]] for every AST node in document order
# (parent = index of the parent node, -1 for the root); extra is the
# StringConstantType of string nodes, the InvocationOperator of commands, the
# parameter name of CommandParameterAst, Splatted of variables, else null;
# comments [[s, e]] from the token stream, nested string tokens included.
param([Parameter(Mandatory)][string]$ManifestPath)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation.Language;
using System.Text;
using System.Text.Json;

public static class ProofKitNative {
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

  static void Comments(IEnumerable<Token> tokens, List<object> output, Func<int, int> B) {
    foreach (var t in tokens) {
      if (t.Kind == TokenKind.Comment) output.Add(new object[] { B(t.Extent.StartOffset), B(t.Extent.EndOffset) });
      var nested = t as StringExpandableToken;
      if (nested != null && nested.NestedTokens != null) Comments(nested.NestedTokens, output, B);
    }
  }

  static object Extra(Ast n) {
    var constant = n as StringConstantExpressionAst;
    if (constant != null) return constant.StringConstantType.ToString();
    var expandable = n as ExpandableStringExpressionAst;
    if (expandable != null) return expandable.StringConstantType.ToString();
    var command = n as CommandAst;
    if (command != null) return command.InvocationOperator.ToString();
    var parameter = n as CommandParameterAst;
    if (parameter != null) return parameter.ParameterName;
    var variable = n as VariableExpressionAst;
    if (variable != null) return variable.Splatted;
    return null;
  }

  public static string Dump(string path) {
    byte[] bytes = File.ReadAllBytes(path);
    int bom = bytes.Length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF ? 3 : 0;
    string text;
    try {
      text = new UTF8Encoding(false, true).GetString(bytes, bom, bytes.Length - bom);
    } catch (DecoderFallbackException) {
      return "{\"st\":\"non_utf8\"}";
    }
    Token[] tokens;
    ParseError[] errors;
    var ast = Parser.ParseInput(text, out tokens, out errors);
    var map = ByteMap(text);
    // Error extents are not always well formed; -1 marks an offset outside the text.
    Func<int, int> B = o => o < 0 || o > text.Length ? -1 : map[o] + bom;
    var errorList = new List<object>();
    foreach (var x in errors)
      errorList.Add(new object[] { x.ErrorId, B(x.Extent.StartOffset), B(x.Extent.EndOffset), x.Message });
    var index = new Dictionary<Ast, int>(ReferenceEqualityComparer.Instance);
    var nodes = new List<object>();
    foreach (var n in ast.FindAll(n => true, true)) {
      int parent = n.Parent != null && index.ContainsKey(n.Parent) ? index[n.Parent] : -1;
      index[n] = nodes.Count;
      nodes.Add(new object[] { n.GetType().Name, B(n.Extent.StartOffset), B(n.Extent.EndOffset), parent, Extra(n) });
    }
    var comments = new List<object>();
    Comments(tokens, comments, B);
    return JsonSerializer.Serialize(new Dictionary<string, object> {
      { "st", "ok" }, { "bom", bom == 3 }, { "err", errorList }, { "nodes", nodes }, { "comments", comments },
    });
  }
}
'@
[Console]::Out.WriteLine((ConvertTo-Json -Compress @{ version = $PSVersionTable.PSVersion.ToString() }))
foreach ($case in ([IO.File]::ReadAllText($ManifestPath) | ConvertFrom-Json)) {
  try {
    $out = [ProofKitNative]::Dump($case.path)
  } catch {
    $out = '{"st":"exception","msg":' + (ConvertTo-Json -Compress $_.Exception.Message) + '}'
  }
  [Console]::Out.WriteLine($out)
}
[Console]::Out.Flush()
