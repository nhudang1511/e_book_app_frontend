import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_model.dart';
class Book extends CustomModel{
  final String? id;
  final String? authodId;
  final List<String>? categoryId;
  final String? description;
  final String? imageUrl;
  final String? language;
  final int? price;
  final DateTime? publishDate;
  final bool? status;
  final String? title;
  final List<String>? bookPreview;
  final int? chapters;
  final String? country;

  Book({
    this.id,
    this.authodId,
    this.categoryId,
    this.description,
    this.imageUrl,
    this.language,
    this.price,
    this.publishDate,
    this.status,
    this.title,
    this.bookPreview,
    this.chapters,
    this.country
  });

  @override
  Book fromJson(Map<String, dynamic> json) {
    Book book = Book(
        id: json['id'],
        authodId: json['authodId'],
        categoryId: List<String>.from(json['categoryId']),
        description: json['description'],
        imageUrl: json['imageUrl'],
        language: json['language'],
        price: json['price'],
        publishDate: (json['publishDate'] as Timestamp).toDate(),
        status: json['status'],
        title: json['title'],
        bookPreview: List<String>.from(json['bookPreview']),
        country: json['country'],
        chapters: json['chapters']
    );
    return book;
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}