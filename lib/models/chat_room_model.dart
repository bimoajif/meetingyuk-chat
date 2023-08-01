class ChatRoomModel {
  final String chatId;
  final String lastMessage;
  final List users;
  final String roomKey;
  final String timesent;

  ChatRoomModel({
    required this.chatId,
    required this.lastMessage,
    required this.users,
    required this.timesent,
    required this.roomKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'lastMessage': lastMessage,
      'users': users.toList(),
      'timesent': timesent,
      'roomKey': roomKey,
    };
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> room) {
    List<dynamic> usersData = room['users'];
    List<UserChatRoom> users = usersData
        .map((userData) => UserChatRoom.fromJson(userData))
        .toList();
    // String roomKey = users.isNotEmpty ? users.first.roomKey : '';
    return ChatRoomModel(
        chatId: room['_id'],
        lastMessage: room['lastMessage'],
        users: users,
        // roomKey: roomKey,
        roomKey: '',
        timesent: room['timesent']);
  }
}

class UserChatRoom {
  final String userId;
  final String name;
  final String profilePic;
  final String roomKey;

  UserChatRoom({
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.roomKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'profilePic': profilePic,
      'roomKey': roomKey,
    };
  }

  factory UserChatRoom.fromJson(Map<String, dynamic> users) {
    return UserChatRoom(
      userId: users['userId'],
      name: users['username'],
      profilePic: users['profilePic'],
      roomKey: users['roomKey'],
    );
  }
}
