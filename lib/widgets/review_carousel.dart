import 'package:fake_app_v1/models/dish_review.dart';
import 'package:fake_app_v1/widgets/review_card.dart';
import 'package:fake_app_v1/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ReviewCarousel extends StatefulWidget {
  final List<DishReview> reviews;

  const ReviewCarousel({
    Key key,
    @required this.reviews,
  }) : super(key: key);

  @override
  _ReviewCarouselState createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<ReviewCarousel> {
  double _rating = 0.0;
  int _numReviews;
  static const double _iconSize = 40.0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    if (widget.reviews != null) {
      _numReviews = widget.reviews.length;
      _rating = widget.reviews
              .fold<double>(0.0, (prev, next) => prev += next.rating) /
          _numReviews;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Valoraciones",
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 8.0),
          StarRating(
            rating: _rating,
            numReviews: _numReviews,
          ),
          SizedBox(height: 8.0),
          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _numReviews,
                itemBuilder: (context, index) {
                  DishReview review = widget.reviews[index];
                  return ReviewCard(
                    headline: review.headline,
                    rating: review.rating,
                    createdBy: review.createdBy,
                    description: review.description,
                  );
                },
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 8),
                  enableInfiniteScroll: true,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  iconSize: _iconSize,
                  onPressed: () => _carouselController.previousPage(),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black38,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  iconSize: _iconSize,
                  onPressed: () => _carouselController.nextPage(),
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
