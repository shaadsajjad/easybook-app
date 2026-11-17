// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_reply_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatReplyModel _$ChatReplyModelFromJson(Map<String, dynamic> json) =>
    ChatReplyModel(
      reply: json['reply'] as String,
      suggestedServices:
          (json['suggestedServices'] as List<dynamic>?)
              ?.map(
                (e) =>
                    SuggestedServiceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

SuggestedServiceModel _$SuggestedServiceModelFromJson(
  Map<String, dynamic> json,
) => SuggestedServiceModel(
  id: json['id'] as String,
  name: json['name'] as String,
);
