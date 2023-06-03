class ChatUser {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  String? id;
  bool? isOnline;
  String? lastActive;
  String? email;
  String? pushToken;

  ChatUser({
    this.image,
    this.about,
    this.name,
    this.createdAt,
    this.id,
    this.isOnline,
    this.lastActive,
    this.email,
    this.pushToken,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['last active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
