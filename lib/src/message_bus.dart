part of dart_message_bus;

class MessageBus {
  StreamController<Message> _streamController;

  MessageBus({bool sync: false}) {
    _streamController = new StreamController<Message>.broadcast(sync: sync);
  }

  StreamSubscription<Message> subscribeAll(void onData(Message message),
      {Function onError, void onDone(), bool cancelOnError})
      => subscribe(null, onData,onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  StreamSubscription<Message> subscribe(String key, void onData(Message message),
      {Function onError, void onDone(), bool cancelOnError}){
    final stream = key == null
        ? _streamController.stream
        : _streamController.stream.where((message) => message.key == key);
    return stream.listen(onData,onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  Future<Message> publish(Message message,
      {String waitForKey, Duration timeout}) {
    if(waitForKey == null){
      _streamController.add(message);
      return new Future.value(message);
    }
    return new FutureMessage(this).getFuture(message, waitForKey, timeout: timeout);
  }

}
