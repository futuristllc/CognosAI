class Expr {
  String callerId;
  String time;
  String result;

  Expr({
    this.callerId, this.time, this.result,
  });

  // to map
  Map<String, dynamic> toMap(Expr expr) {
    Map<String, dynamic> exprmap = Map();
    exprmap["caller_id"] = expr.callerId;
    exprmap["time"] = expr.time;
    exprmap["result"] = expr.result;
    return exprmap;
  }

  Expr.fromMap(Map exprmap) {
    this.callerId = exprmap["caller_id"];
    this.time = exprmap["time"];
    this.result = exprmap["result"];
  }
}