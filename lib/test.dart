import 'package:mongo_dart/mongo_dart.dart';
// import 'dart:io' show Platform;

// String host = Platform.environment['MONGO_DART_DRIVER_HOST'] ?? '127.0.0.1';
// String port = Platform.environment['MONGO_DART_DRIVER_PORT'] ?? '27017';

void main() async {
  var db = Db(
      'mongodb://bimoajif:12345@cluster0-shard-00-00.vjy66.mongodb.net:27017,cluster0-shard-00-01.vjy66.mongodb.net:27017,cluster0-shard-00-02.vjy66.mongodb.net:27017/meetingyuk-chat?ssl=true&replicaSet=atlas-13ew1s-shard-0&authSource=admin&retryWrites=true&w=majority');
  var message = {
    'lastMessage': 'test',
    'name': 'Bimo',
    'profilePic': '',
    'timesent': DateTime.now(),
  };

  await db.open();
  // await db.drop();

  print('====================================================================');
  print('>> Adding message');
  var collection = db.collection('chats');
  await collection.insert(message);

  // await db.ensureIndex('users', name: 'meta', keys: {'_id': 1});
  // await collection.find().forEach((v) {
  //   print(v);
  //   message[v['chats'].toString()] = v;
  // });
  print('====================================================================');

  final resp = await collection.find(where.sortBy('timesent')).toList();
  for(int i = 0; i < resp.length; i++) {
    print(resp[i]);
  }
  // print('>> Adding Users');
  // var usersCollection = db.collection('users');
  // await usersCollection.insertMany([
  //   {
  //     'login': 'jdoe',
  //     'name': 'John Doe',
  //     'email': 'john@doe.com',
  //   },
  //   {
  //     'login': 'lsmith',
  //     'name': 'Lucy Smith',
  //     'email': 'lucy@smith.com',
  //   }
  // ]);
  // await db.ensureIndex('users', keys: {'login': -1});
  // await usersCollection.find().forEach((user) {
  //   users[user['login'].toString()] = user;
  //   print(user);
  // });
  // print('====================================================================');

  // print('>> Users ordered by login descending');
  // await usersCollection.find(where.sortBy('login', descending: true)).forEach(
  //     (user) =>
  //         print("[${user['login']}]:[${user['name']}]:[${user['email']}]"));
  // print('====================================================================');

  // print('>> Adding articles');
  // var articlesCollection = db.collection('articles');
  // await articlesCollection.insertMany([
  //   {
  //     'title': 'Caminando por Buenos Aires',
  //     'body': 'Las callecitas de Buenos Aires tienen ese no se que...',
  //     'author_id': authors['Jorge Luis Borges']?['_id'],
  //   },
  //   {
  //     'title': 'I must have seen thy face before',
  //     'body': 'Thine eyes call me in a new way',
  //     'author_id': authors['William Shakespeare']?['_id'],
  //     'comments': [
  //       {
  //         'user_id': users['jdoe']?['_id'],
  //         'body': 'great article!',
  //       }
  //     ],
  //   }
  // ]);
  // print('====================================================================');

  // print('>> Articles ordered by title ascending');
  // await articlesCollection.find(where.sortBy('title')).forEach((article) {
  //   print("[${article['title']}]:[${article['body']}]:"
  //       "[${article['author_id'].toHexString()}]");
  // });
  await db.close();
}
