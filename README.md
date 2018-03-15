# dart_message_bus

A useful implementation of
[publish–subscribe messaging pattern][wiki] using Dart [Stream][stream].

[![Pub Package][pub-img]][pub]
[![GitHub release][gh-release-img]][gh-release]
[![Build Status][travis-build-img]][travis-build]
[![GitHub license][gh-license-img]][gh-license]
[![Twitter][tw-img]][tw]

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

    import 'package:dart_message_bus/dart_message_bus.dart';

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

    import 'package:dart_message_bus/dart_message_bus.dart';

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

## Contributing [![GitHub contributors][gh-ctrb-img]][gh-ctrb]

Want to contribute? Great! Open an issue.

----

[![Documentation Status][docs-img]][docs]
[![Github all releases][gh-release-all-img]][gh-release]
[![GitHub version][gh-version-img]][gh-version]
[![GitHub issues][gh-issues-img]][gh-issues]
[![GitHub forks][gh-forks-img]][gh-forks]
[![GitHub stars][gh-stars-img]][gh-stars]
[![HitCount][hits-img]][hits]


[tracker]: https://github.com/javad-amiry/dart_message_bus/issues
[wiki]: https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern
[stream]: https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:async.Stream
[strongly-typed]: https://en.wikipedia.org/wiki/Strong_and_weak_typing

[travis-build-img]: https://travis-ci.org/javad-amiry/dart_message_bus.svg?branch=master
[travis-build]: https://travis-ci.org/javad-amiry/dart_message_bus

[pub-img]: https://img.shields.io/pub/v/dart_message_bus.svg
[pub]: https://pub.dartlang.org/packages/dart_message_bus

[git]: https://github.com/javad-amiry/dart_message_bus

[gh-release-img]: https://img.shields.io/github/release/javad-amiry/dart_message_bus.svg
[gh-release]: https://GitHub.com/javad-amiry/dart_message_bus/releases/

[gh-ctrb-img]: https://img.shields.io/github/contributors/javad-amiry/dart_message_bus.svg
[gh-ctrb]: https://GitHub.com/javad-amiry/dart_message_bus/graphs/contributors/

[gh-version-img]: https://badge.fury.io/gh/dart_message_bus.svg
[gh-version]: https://github.com/javad-amiry/dart_message_bus

[gh-license-img]: https://img.shields.io/github/license/javad-amiry/dart_message_bus.svg
[gh-license]: https://github.com/javad-amiry/dart_message_bus/blob/master/LICENSE

[gh-release-all-img]: https://img.shields.io/github/downloads/javad-amiry/dart_message_bus/total.svg

[gh-issues-img]: https://img.shields.io/github/issues/javad-amiry/dart_message_bus.svg
[gh-issues]: https://github.com/javad-amiry/dart_message_bus/issues

[gh-forks-img]: https://img.shields.io/github/forks/javad-amiry/dart_message_bus.svg
[gh-forks]: https://github.com/javad-amiry/dart_message_bus/network

[gh-stars-img]: https://img.shields.io/github/stars/javad-amiry/dart_message_bus.svg
[gh-stars]: https://github.com/javad-amiry/dart_message_bus/stargazers

[hits-img]: http://hits.dwyl.io/javad-amiry/dart_message_bus.svg
[hits]: http://hits.dwyl.io/javad-amiry/dart_message_bus

[tw-img]: https://img.shields.io/twitter/url/https/github.com/javad-amiry/dart_message_bus.svg
[tw]: https://twitter.com/intent/tweet?text=Wow!%20%23dart%20%23dartlang&url=https%3A%2F%2Fgithub.com%2Fjavad-amiry%2Fdart_message_bus

[docs-img]: https://readthedocs.org/projects/dart-message-bus/badge/?version=latest
[docs]: http://dart-message-bus.readthedocs.io/en/latest/?badge=latest