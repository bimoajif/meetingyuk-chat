class KeyPair {
  final String userId;
  final String publicKey;
  final String privateKey;

  KeyPair({
    required this.userId,
    required this.publicKey,
    required this.privateKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }

  factory KeyPair.fromJson(Map<String, dynamic> map) {
    return KeyPair(
      userId: map['userId'] ?? '',
      publicKey: map['publicKey'] ?? '',
      privateKey: map['privateKey'] ?? '',
    );
  }
}
