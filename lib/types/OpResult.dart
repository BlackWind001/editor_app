class OpResult {
  bool success = false;
  String? errMsg;
  dynamic data;

  OpResult({ required this.success, this.errMsg, this.data });
}