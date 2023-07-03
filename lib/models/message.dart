class Message {
  Message({this.msg, this.read, this.told, this.type, this.fromid, this.sent});

  String? msg;
  String? read;
  String? told;
  String? fromid;
  String? sent;
  Type? type;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromid = json['fromid'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['type'] = type;
    data['fromid'] = fromid;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }