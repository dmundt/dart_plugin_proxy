
library plugin_proxy;

import 'dart:isolate';
import 'dart:mirrors';
//import 'package:meta/meta.dart';

abstract class Plugin {
  inc(num value);
  add(num value1, num value2);
}

class PluginProxy implements Plugin {
  SendPort _sender;

  PluginProxy(this._sender);
  PluginProxy.spawnUri(String uri) {
    _sender = spawnUri(uri);
  }

  inc(num value) => _sender.call(['inc', [value]]);
  add(num value1, num value2) => _sender.call(['add', [value1, value2]]);
}

main() {
  var proxy = new PluginProxy.spawnUri('plugin.dart');
  proxy.inc(1).then((result) {
    print('inc result: $result');
  });
  proxy.add(10.4, 12.3).then((result) {
    print('add result: $result');
  });
}
