import 'package:kinder_world/core/models/public_content.dart';

class LegalContentPayload {
  const LegalContentPayload({
    this.body,
    this.content,
    this.item,
  });

  final String? body;
  final String? content;
  final PublicContentItem? item;

  String get resolvedBody {
    final directBody = (body ?? '').trim();
    if (directBody.isNotEmpty) {
      return directBody;
    }
    final fallbackContent = (content ?? '').trim();
    if (fallbackContent.isNotEmpty) {
      return fallbackContent;
    }
    final itemBodyEn = (item?.bodyEn ?? '').trim();
    if (itemBodyEn.isNotEmpty) {
      return itemBodyEn;
    }
    final itemBodyAr = (item?.bodyAr ?? '').trim();
    if (itemBodyAr.isNotEmpty) {
      return itemBodyAr;
    }
    return '';
  }

  String resolvedBodyForLanguageCode(String languageCode) {
    final normalizedCode = languageCode.toLowerCase();
    final localizedItemBody = normalizedCode.startsWith('ar')
        ? (item?.bodyAr ?? '').trim()
        : (item?.bodyEn ?? '').trim();
    if (localizedItemBody.isNotEmpty) {
      return localizedItemBody;
    }

    final alternateItemBody = normalizedCode.startsWith('ar')
        ? (item?.bodyEn ?? '').trim()
        : (item?.bodyAr ?? '').trim();
    if (alternateItemBody.isNotEmpty) {
      return alternateItemBody;
    }

    return resolvedBody;
  }

  factory LegalContentPayload.fromJson(Map<String, dynamic> json) {
    final rawItem = json['item'];
    return LegalContentPayload(
      body: json['body']?.toString(),
      content: json['content']?.toString(),
      item: rawItem is Map<String, dynamic>
          ? PublicContentItem.fromJson(rawItem)
          : rawItem is Map
              ? PublicContentItem.fromJson(Map<String, dynamic>.from(rawItem))
              : null,
    );
  }
}
