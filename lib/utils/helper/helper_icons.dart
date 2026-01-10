import 'package:flutter/material.dart';

class IconHelper {
  // Map of icon codes to predefined IconData
  static const Map<int, IconData> iconMap = {
    // Home icons
    58152: Icons.home,
    59535: Icons.apartment,
    57404: Icons.business,
    57728: Icons.cottage,
    59530: Icons.villa,
    
    // Device icons
    59840: Icons.lightbulb,
    57399: Icons.air,
    57414: Icons.ac_unit,
    58163: Icons.tv,
    57809: Icons.computer,
    59574: Icons.phone_android,
    59869: Icons.laptop,
    59770: Icons.kitchen,
    59890: Icons.microwave,
    59956: Icons.local_laundry_service,
    60299: Icons.power,
    58751: Icons.router,
    59678: Icons.speaker,
    59064: Icons.videogame_asset,
    58895: Icons.light,
    
    // Add more as needed
  };

  /// Get IconData from code point, with fallback to default icon
  static IconData getIcon(dynamic iconCodePoint, {IconData defaultIcon = Icons.power}) {
    if (iconCodePoint == null) return defaultIcon;
    
    int? code;
    if (iconCodePoint is int) {
      code = iconCodePoint;
    } else if (iconCodePoint is String) {
      code = int.tryParse(iconCodePoint);
    }
    
    if (code == null) return defaultIcon;
    
    return iconMap[code] ?? defaultIcon;
  }

  /// Get all available home icons for selection
  static List<MapEntry<int, IconData>> getHomeIcons() {
    return [
      const MapEntry(58152, Icons.home),
      const MapEntry(59535, Icons.apartment),
      const MapEntry(57404, Icons.business),
      const MapEntry(57728, Icons.cottage),
      const MapEntry(59530, Icons.villa),
    ];
  }

  /// Get all available device icons for selection
  static List<MapEntry<int, IconData>> getDeviceIcons() {
    return [
      const MapEntry(59840, Icons.lightbulb),
      const MapEntry(57399, Icons.air),
      const MapEntry(57414, Icons.ac_unit),
      const MapEntry(58163, Icons.tv),
      const MapEntry(57809, Icons.computer),
      const MapEntry(59574, Icons.phone_android),
      const MapEntry(59869, Icons.laptop),
      const MapEntry(59770, Icons.kitchen),
      const MapEntry(59890, Icons.microwave),
      const MapEntry(59956, Icons.local_laundry_service),
      const MapEntry(60299, Icons.power),
      const MapEntry(58751, Icons.router),
      const MapEntry(59678, Icons.speaker),
      const MapEntry(59064, Icons.videogame_asset),
      const MapEntry(58895, Icons.light),
    ];
  }
}