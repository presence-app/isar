import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import 'entities.dart';
import 'geo.dart';
import 'media.dart';
import 'user.dart';
import 'util.dart';

part 'tweet.g.dart';

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
@collection
class Tweet {
  Tweet();

  factory Tweet.fromJson(Map<String, dynamic> json) => _$TweetFromJson(json);

  Id? isarId;

  @JsonKey(fromJson: convertTwitterDateTime)
  DateTime? createdAt;

  String? idStr;

  String? source;

  bool? truncated;

  String? inReplyToStatusIdStr;

  String? inReplyToUserIdStr;

  String? inReplyToScreenName;

  User? user;

  Coordinates? coordinates;

  Place? place;

  String? quotedStatusIdStr;

  bool? isQuoteStatus;

  int? quoteCount;

  int? replyCount;

  int? retweetCount;

  int? favoriteCount;

  Entities? entities;

  Entities? extendedEntities;

  bool? favorited;

  bool? retweeted;

  bool? possiblySensitive;

  bool? possiblySensitiveAppealable;

  CurrentUserRetweet? currentUserRetweet;

  String? lang;

  QuotedStatusPermalink? quotedStatusPermalink;

  String? fullText;

  List<int>? displayTextRange;

  Map<String, dynamic> toJson() => _$TweetToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
@embedded
class CurrentUserRetweet {
  CurrentUserRetweet();

  factory CurrentUserRetweet.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserRetweetFromJson(json);

  String? idStr;

  Map<String, dynamic> toJson() => _$CurrentUserRetweetToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
@embedded
class QuotedStatusPermalink {
  QuotedStatusPermalink();

  factory QuotedStatusPermalink.fromJson(Map<String, dynamic> json) =>
      _$QuotedStatusPermalinkFromJson(json);

  String? url;

  String? expanded;

  String? display;

  Map<String, dynamic> toJson() => _$QuotedStatusPermalinkToJson(this);
}
