part of message_bus;

class FutureMessage {
  final MessageBus _bus;
  final Completer<Message> _completer = new Completer<Message>();
  StreamSubscription<Message> _subscription;
  Timer _timer;

  FutureMessage(this._bus);

  Future<Message> getFuture(Message message, String waitForKey,
      {Duration timeout}) {
    timeout = timeout ?? const Duration(seconds: 30);

    // subscribe for waitFor callback
    _subscription = _bus.subscribe(waitForKey, _complete);

    // publish message
    _bus.publish(message);

    // wait for timeout
    _timer = new Timer(timeout,(){
      print('Timer finished.');
      _complete(new Message.empty(waitForKey));}
      );

    // return an awaitable Future
    return _completer.future;
  }

  void _complete(Message message) {
    _timer?.cancel();
    _subscription.cancel();
    if (!_completer.isCompleted) _completer.complete(message);
  }
}