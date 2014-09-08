library ace_editor_element;

import 'dart:html';
import 'dart:js';
import 'package:ace/ace.dart';
import 'package:ace/proxy.dart';
import 'package:polymer/polymer.dart';
import 'package:logging/logging.dart';

/**
 * A Polymer ace-editor element.
 */
@CustomTag('ace-editor')
class AceEditor extends PolymerElement {
  @published
  String theme = "chrome";

  @published
  String mode = "dart";

  JsObject _aceConfig;

  Editor _editor;
  Editor get editor => _editor;

  EditSession get session => _editor.session;

  String get value => session.value;
  set value(String value) => session.value = value;

  AceEditor.created() : super.created() {
    _initializeAceEditor();
  }

  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);

    if (name == "theme") {
      _changeTheme(theme);
    }

    if (name == "mode") {
      _changeMode(mode);
    }
  }

  void _initializeAceEditor() {
    implementation = ACE_PROXY_IMPLEMENTATION;

    _aceConfig = context["ace"]["config"];
    _aceConfig.callMethod("set", ["basePath", "/packages/ace_editor/src/ace-js"]);

    _applyAceStyles();

    _editor = edit($["editor"]);
    _editor.onChange.forEach((delta) => dispatchEvent(new CustomEvent("change", detail: delta)));

    _changeTheme(theme);
    _changeMode(mode);

    value = text;
  }

  void _changeTheme(String name) {
    var theme = new Theme.named(name);
    _editor.theme = theme;

    // The theme stylesheet is asynchronously added to the document. When it's ready add it
    // to the element's shadow dom. Otherwise the theme styles won't apply.
    theme.onLoad.then((_) {
      // There's a stack overflow bug when calling ace.dart's `Theme.cssText`.
      var cssText = theme.jsProxy["cssText"];
      shadowRoot.append(new StyleElement()..text = cssText);
    });
  }

  void _changeMode(String name) {
    session.mode = new Mode.named(name);
  }

  void _applyAceStyles() {
    var selectors = ["#ace_editor", "#ace-tm"];
    var styles = document.head.querySelectorAll(selectors.join(","));

    for (var style in styles) {
      shadowRoot.children.add(style.clone(true));
    }
  }
}

Logger _logger = new Logger("ace_editor_element");
