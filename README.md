# message_bus

A useful implementation of
[publish–subscribe messaging pattern][wiki] using Dart [Stream][stream].

(From wikipedia:) In software architecture, publish–subscribe is a messaging pattern
where senders of messages, called publishers, do not program
the messages to be sent directly to specific receivers,
called subscribers, but instead categorize published messages
into classes without knowledge of which subscribers, if any,
there may be. Similarly, subscribers express interest in one
or more classes and only receive messages that are of interest,
without knowledge of which publishers, if any, there are.
Read more on [wiki][wiki].

In this particular implementation, I changed the messages types
to a [strongly-typed][strongly-typed] class
named `Message` which holds some useful information about message
and the key for listening and publishing messages is a `String` key
which made it easier to identify and group messages.

## Usage

#### simple usage example:

    import 'package:message_bus/message_bus.dart';

    main() {
      // usually the MessageBus is a singleton shared instance
      final bus = new MessageBus();

      // in service A which is a subscriber
      bus.subscribe('message-key', (Message m) {
        // use m:
        var data = m.data;
        // etc.
      });

      // in service B which is a publisher
      var data = new YourOriginalMessageDataClass();
      var message = new Message('message-key', data: data);
      bus.publish(message);
    }

#### Advanced scenario

Say `ServiceA` publishes a message, and wants to wait for say 30
seconds for a certain message-back, and then continue executing
-no matter there was a message-back or not. The `ServiceB` is one of
the subscribers, and when he received the message, makes a
http-request asynchronously -say it may takes 1 to 60 seconds- and
when the request got completed, it publishes a specified message
-which actually is a message-back for `ServiceA`. The snippet below
will do the work:

    import 'package:message_bus/message_bus.dart';

    class ServiceA {
      final MessageBus _bus;
      ServiceA(this._bus);
      Future<Null> run() async {
        var callbackMessage = await _bus.publish(
          new Message('message-a', data: new DataA()),
          waitForKey: 'message-b',
          timeout: const Duration(seconds: 30)
        );
        if(callbackMessage.isEmpty) {
          // means the another service's message didnot received
          // and timeout occured.
        } else {
          // the callback from another service received
          // and callbackMessage.data contains callback-data.
        }
      }
    }

    class ServiceB {
      final MessageBus _bus;
      ServiceB(this._bus);
      Future<Null> run() async {
        _bus.subscribe('message-a', (Message m) async {
          // when this service received a 'message-a' message,
          // it performs a long-time action. For example
          // calling an API. To simulate latency we are
          // delaying with this line:
          await new Future.delayed(const Duration(seconds: 5));

          // after the long-time action completed, this
          // service publishes a new message names 'message-b':
          var data = new DataB();
          var message = new Message('message-b', data: data);
          _bus.publish(message);
        });
      }
    }

    main() {
      // usually the MessageBus is a singleton shared instance
      final bus = new MessageBus();

      var serviceA = new ServiceA(bus);
      var serviceB = new ServiceB(bus);

      // first, run serviceB to subcribe to message-a
      serviceB.run();

      // then you can run serviceA to publish message-a
      // and also receive message-b if there is any
      serviceA.run();
    }

For a complete scenario please clone the [git repo][git] and see and run tests.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/javad-amiry/message_bus/issues
[wiki]: https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern
[stream]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:async.Stream
[strongly-typed]: https://en.wikipedia.org/wiki/Strong_and_weak_typing
[git]: https://github.com/javad-amiry/message_bus