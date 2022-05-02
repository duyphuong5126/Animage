class Post {
  int? id;
  String? tags;
  int? createdAt;
  int? updatedAt;
  int? creatorId;
  int? approverId;
  String? author;
  int? change;
  String? source;
  int? score;
  String? md5;
  int? fileSize;
  String? fileExt;
  String? fileUrl;
  bool? isShownInIndex;
  String? previewUrl;
  int? previewWidth;
  int? previewHeight;
  int? actualPreviewWidth;
  int? actualPreviewHeight;
  String? sampleUrl;
  int? sampleWidth;
  int? sampleHeight;
  int? sampleFileSize;
  String? jpegUrl;
  int? jpegWidth;
  int? jpegHeight;
  int? jpegFileSize;
  String? rating;
  bool? isRatingLocked;
  bool? hasChildren;
  int? parentId;
  String? status;
  bool? isPending;
  int? width;
  int? height;
  bool? isHeld;
  String? framesPendingString;

  // Todo - what are these properties?
  /*List<Null>? framesPending;
  String? framesString;
  List<Null>? frames;*/
  bool? isNoteLocked;
  int? lastNotedAt;
  int? lastCommentedAt;

  Post(
      {this.id,
      this.tags,
      this.createdAt,
      this.updatedAt,
      this.creatorId,
      this.approverId,
      this.author,
      this.change,
      this.source,
      this.score,
      this.md5,
      this.fileSize,
      this.fileExt,
      this.fileUrl,
      this.isShownInIndex,
      this.previewUrl,
      this.previewWidth,
      this.previewHeight,
      this.actualPreviewWidth,
      this.actualPreviewHeight,
      this.sampleUrl,
      this.sampleWidth,
      this.sampleHeight,
      this.sampleFileSize,
      this.jpegUrl,
      this.jpegWidth,
      this.jpegHeight,
      this.jpegFileSize,
      this.rating,
      this.isRatingLocked,
      this.hasChildren,
      this.parentId,
      this.status,
      this.isPending,
      this.width,
      this.height,
      this.isHeld,
      this.framesPendingString,
      /*this.framesPending,
        this.framesString,
        this.frames,*/
      this.isNoteLocked,
      this.lastNotedAt,
      this.lastCommentedAt});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    creatorId = json['creator_id'];
    approverId = json['approver_id'];
    author = json['author'];
    change = json['change'];
    source = json['source'];
    score = json['score'];
    md5 = json['md5'];
    fileSize = json['file_size'];
    fileExt = json['file_ext'];
    fileUrl = json['file_url'];
    isShownInIndex = json['is_shown_in_index'];
    previewUrl = json['preview_url'];
    previewWidth = json['preview_width'];
    previewHeight = json['preview_height'];
    actualPreviewWidth = json['actual_preview_width'];
    actualPreviewHeight = json['actual_preview_height'];
    sampleUrl = json['sample_url'];
    sampleWidth = json['sample_width'];
    sampleHeight = json['sample_height'];
    sampleFileSize = json['sample_file_size'];
    jpegUrl = json['jpeg_url'];
    jpegWidth = json['jpeg_width'];
    jpegHeight = json['jpeg_height'];
    jpegFileSize = json['jpeg_file_size'];
    rating = json['rating'];
    isRatingLocked = json['is_rating_locked'];
    hasChildren = json['has_children'];
    parentId = json['parent_id'];
    status = json['status'];
    isPending = json['is_pending'];
    width = json['width'];
    height = json['height'];
    isHeld = json['is_held'];
    framesPendingString = json['frames_pending_string'];
    /*if (json['frames_pending'] != null) {
      framesPending = <Null>[];
      json['frames_pending'].forEach((v) {
        framesPending!.add(Null.fromJson(v));
      });
    }
    framesString = json['frames_string'];
    if (json['frames'] != null) {
      frames = <Null>[];
      json['frames'].forEach((v) {
        frames!.add(new Null.fromJson(v));
      });
    }*/
    isNoteLocked = json['is_note_locked'];
    lastNotedAt = json['last_noted_at'];
    lastCommentedAt = json['last_commented_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tags'] = tags;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['creator_id'] = creatorId;
    data['approver_id'] = approverId;
    data['author'] = author;
    data['change'] = change;
    data['source'] = source;
    data['score'] = score;
    data['md5'] = md5;
    data['file_size'] = fileSize;
    data['file_ext'] = fileExt;
    data['file_url'] = fileUrl;
    data['is_shown_in_index'] = isShownInIndex;
    data['preview_url'] = previewUrl;
    data['preview_width'] = previewWidth;
    data['preview_height'] = previewHeight;
    data['actual_preview_width'] = actualPreviewWidth;
    data['actual_preview_height'] = actualPreviewHeight;
    data['sample_url'] = sampleUrl;
    data['sample_width'] = sampleWidth;
    data['sample_height'] = sampleHeight;
    data['sample_file_size'] = sampleFileSize;
    data['jpeg_url'] = jpegUrl;
    data['jpeg_width'] = jpegWidth;
    data['jpeg_height'] = jpegHeight;
    data['jpeg_file_size'] = jpegFileSize;
    data['rating'] = rating;
    data['is_rating_locked'] = isRatingLocked;
    data['has_children'] = hasChildren;
    data['parent_id'] = parentId;
    data['status'] = status;
    data['is_pending'] = isPending;
    data['width'] = width;
    data['height'] = height;
    data['is_held'] = isHeld;
    data['frames_pending_string'] = framesPendingString;
    /*if (this.framesPending != null) {
      data['frames_pending'] =
          this.framesPending!.map((v) => v.toJson()).toList();
    }
    data['frames_string'] = this.framesString;
    if (this.frames != null) {
      data['frames'] = this.frames!.map((v) => v.toJson()).toList();
    }*/
    data['is_note_locked'] = isNoteLocked;
    data['last_noted_at'] = lastNotedAt;
    data['last_commented_at'] = lastCommentedAt;
    return data;
  }
}
