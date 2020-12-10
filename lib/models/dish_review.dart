import 'package:meta/meta.dart';

class DishReview {
  final double rating;
  final String headline;
  final String createdBy;
  final String description;

  DishReview({
    @required this.rating,
    @required this.headline,
    @required this.createdBy,
    @required this.description,
  });
}
