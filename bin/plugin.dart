
import 'dart:isolate';
import 'dart:mirrors';
//import 'package:meta/meta.dart';
import 'plugin_proxy.dart';

class ComputePlugin implements Plugin {
  inc(num value) => value + 1;
  add(num value1, num value2) => value1 + value2;
}

main() {
  var plugin = new ComputePlugin();
  var mirror = reflect(plugin);

  port.receive((msg, replyTo) {
    mirror.invoke(msg[0], msg[1]).then((mirror) {
      if (replyTo != null) {
        replyTo.send(mirror.reflectee);
      }
    });
  });
}
