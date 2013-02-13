library plugin;

import 'dart:isolate';
import 'dart:mirrors';
import 'plugin_proxy.dart';

// Remote class 'seen' by client through the proxy class
// living in another isolate. The proxy object serializes all method,
// setter, and getter calls and sends them through the isolate's port.
class ComputePlugin implements Plugin {
  var value = '';
  inc(value) => value + 1;
  add(value1, value2) => value1 + value2;
}

main() {
  var plugin = new ComputePlugin();
  var mirror = reflect(plugin);

  // Method/getter/setter deserialization.
  port.receive((msg, replyTo) {
    mirror.invoke(msg[0], msg[1]).then((mirror) {
      if (replyTo != null) {
        replyTo.send(mirror.reflectee);
      }
    });
  });
}
