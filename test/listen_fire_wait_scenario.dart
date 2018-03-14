import 'dart:async';
import 'package:message_bus/message_bus.dart';
import 'package:test/test.dart';

class TriggerParam {
  int value;
}

class CallbackParam {
  int value;
}

class ListenFireWaitScenario {
  void run() {
    test('it should get callback result in case timeout doesn`t happend',()async{
      await getResultTest();
    });
    test('it shouldn`t get callback result in case timeout happend.',()async{
      await cantGetResultTest();
    });
  }
  Future<Null> getResultTest() async {
    final bus = new MessageBus();

    bus.subscribe('TriggerMessage',(m) async {
      await new Future.delayed(const Duration(seconds: 2));
      var data = new CallbackParam()..value = m.data.value;
      var message = new Message('CallbackMessage', data: data);
      bus.publish(message);
    });

    var callbackMessage = await bus.publish(
        new Message('TriggerMessage', data: new TriggerParam()..value = 10),
        waitForKey: 'CallbackMessage',
        timeout: const Duration(seconds: 4));

    expect(callbackMessage.runtimeType, equals(Message));

    expect(callbackMessage.isEmpty, isFalse);

    expect(callbackMessage?.data?.runtimeType, equals(CallbackParam));

    expect(callbackMessage?.data?.value, equals(10));
  }

  Future<Null> cantGetResultTest() async {
    final bus = new MessageBus();

    bus.subscribe('TriggerMessage', (m) async {
      await new Future.delayed(const Duration(seconds: 4));
      var data = new CallbackParam()..value = m.data.value;
      var message = new Message('CallbackMessage', data: data);
      bus.publish(message);
    });

    var callbackMessage = await bus.publish(
        new Message('TriggerMessage', data: new TriggerParam()..value = 10),
        waitForKey: 'CallbackMessage',
        timeout: const Duration(seconds: 2));

    expect(callbackMessage.runtimeType, equals(Message));

    expect(callbackMessage.isEmpty, isTrue);

    expect(callbackMessage.data, isNull);

    expect(callbackMessage?.data?.value, isNull);
  }
  
}
