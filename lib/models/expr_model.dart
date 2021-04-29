class Expr {
  String uid;
  String time;
  String result;

  Expr({
    this.uid, this.time, this.result,
  });

  // to map
  Map<String, dynamic> toMap(Expr expr) {
    Map<String, dynamic> exprmap = Map();
    exprmap["uid"] = expr.uid;
    exprmap["time"] = expr.time;
    exprmap["result"] = expr.result;
    return exprmap;
  }

  Expr.fromMap(Map exprmap) {
    this.uid = exprmap["uid"];
    this.time = exprmap["time"];
    this.result = exprmap["result"];
  }
}