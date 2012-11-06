
library plugin_proxy;

import 'dart:isolate';
import 'dart:mirrors';

abstract class Plugin {
  String value;
  inc(num value);
  add(num value1, num value2);
}

class PluginProxy implements Plugin {
  SendPort _sender;

  PluginProxy(this._sender);
  PluginProxy.spawnUri(String uri) {
    _sender = spawnUri(uri);
  }

  get value => _sender.call(['get:value', []]);
  set value(value) => _sender.call(['set:value', [value]]);
  inc(value) => _sender.call(['inc', [value]]);
  add(value1, value2) => _sender.call(['add', [value1, value2]]);
}

main() {
  var proxy = new PluginProxy.spawnUri('plugin.dart');
  proxy.inc(1).then((result) {
    print('inc result: $result');
  });
  proxy.add(10.4, 12).then((result) {
    print('add result: $result');
  });
  proxy.value = 'Hello World!';
  proxy.value.then((result) {
    print('val result: $result');
  });
}
