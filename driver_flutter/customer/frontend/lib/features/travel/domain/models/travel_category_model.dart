import 'package:flutter/material.dart';

class TravelDestination {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String estimatedTravelTime;

  const TravelDestination({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedTravelTime,
  });
}

class TravelCategoryConfig {
  final String id;
  final String title;
  final String subtitle;
  final List<TravelDestination> destinations;

  const TravelCategoryConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.destinations,
  });
}
