library plugin_proxy;

import 'dart:async';
import 'dart:isolate';

// Universal plugin proxy for calling remote object instances
// living in another isolate.
class Proxy {
  final SendPort _sender;

  Proxy(this._sender);
  Proxy.spawnUri(String uri) : _sender = spawnUri(uri);

  // Automatic method/setter/getter call serializer.
  // Limitations:
  //   - no named arguments
  //   - no closures / callbacks
  noSuchMethod(InvocationMirror mirror) {
    var memberName = mirror.memberName;
    if (mirror.isSetter) {
      memberName = 'set:$memberName'.replaceAll('=', '');
    } else if (mirror.isGetter) {
      memberName = 'get:$memberName';
    }
    return _sender.call([memberName, mirror.positionalArguments]);
  }
}

// Interface declaration of proxy and remote class for testing the
// universal plugin proxy.
abstract class Plugin {
  var value;
  inc(num value);
  add(num value1, num value2);
}

// Local proxy class for the remote plugin living in another isolate.
// The plugin code is dynamically loaded by only referencing the script name.
class PluginProxy extends Proxy implements Plugin {
  PluginProxy() : super.spawnUri('plugin.dart');
}

main() {
  var proxy = new PluginProxy();
  proxy.inc(1).then((result) {
    print('inc: $result');
  });
  proxy.add(42, 13).then((result) {
    print('add: $result');
  });
  proxy.value = 'Hello World!';
  proxy.value.then((result) {
    print('val: $result');
  });
}
