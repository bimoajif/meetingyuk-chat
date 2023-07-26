// ignore_for_file: constant_identifier_names

// --------------------------------------------------------------
// Enum class for message type
// --------------------------------------------------------------
enum MessageEnum {
  TEXT('text'),
  IMAGE('image'),
  FILE('file'),
  PRODUCT('product');

  const MessageEnum(this.type);
  final String type;
}

extension ConvertMessage on String {
  MessageEnum toEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.TEXT;
      case 'image':
        return MessageEnum.IMAGE;
      case 'file':
        return MessageEnum.FILE;
      case 'product':
        return MessageEnum.PRODUCT;
      default:
        return MessageEnum.TEXT;
    }
  }
}
