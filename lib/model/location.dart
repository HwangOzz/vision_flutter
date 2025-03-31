class Review {
  final String urlImage;

  Review({required this.urlImage});
}

class Location {
  final String name;
  final String latitude;
  final String longitude;
  final String addressLine1;
  final String addressLine2;
  final int starRating;
  final String urlImage;
  final List<Review> reviews;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.addressLine1,
    required this.addressLine2,
    required this.starRating,
    required this.urlImage,
    required this.reviews,
  });
}
