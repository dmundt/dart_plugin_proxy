library plugin;

import 'dart:isolate';
import 'dart:mirrors';
import 'plugin_proxy.dart';

// Remote class 'seen' by client through the proxy class
// living in another isolate. The proxy object serializes all method,
// setter, and getter calls and sends them through the isolate's port.
class PluginImpl implements Plugin {
  var value = '';
  inc(value) => value + 1;
  add(value1, value2) => value1 + value2;
}

void publish(dynamic obj) {
  var mirror = reflect(plugin);

  // Method/getter/setter deserialization.
  port.receive((msg, replyTo) {
    assert(replyTo != null);

    var memberType = msg[0];
    var memberName = new Symbol(msg[1]);

    if (memberType == 's') {
      mirror.setFieldAsync(memberName, msg[2]);
    } else if (memberType == 'g') {
      mirror.getFieldAsync(memberName).then((mirror) {
        replyTo.send(mirror.reflectee);
      });
    } else if (memberType == 'f') {
      mirror.invokeAsync(memberName, msg[2]).then((mirror) {
        replyTo.send(mirror.reflectee);
      });
    }
}

main() {
  publish(new PluginImpl());
}
