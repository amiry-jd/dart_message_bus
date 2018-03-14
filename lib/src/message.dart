part of dart_message_bus;

class Message {
  bool _cancelRequested = false;
  bool _isEmpty = false;

  final String key;
  final dynamic data;

  bool get cancelRequested => _cancelRequested;

  bool get isEmpty => _isEmpty;

  Type get dataType => data?.runtimeType;

  Message(this.key, {this.data});

  void requestCancel() => _cancelRequested = true;

  factory Message.empty(String key) => new Message(key).._isEmpty = true;
}
