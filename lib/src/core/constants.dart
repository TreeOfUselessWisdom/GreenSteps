class AppConstants {
  // App Information
  static const String appName = 'GreenSteps';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Sustainable Living Guide';

  // Emission Factors (kg CO2e)
  static const Map<String, double> emissionFactors = {
    'car_km': 0.21,
    'bus_km': 0.05,
    'train_km': 0.04,
    'bike_km': 0.0,
    'walk_km': 0.0,
    'electricity_kwh': 0.475,
    'gas_m3': 2.03,
    'heating_kwh': 0.216,
    'beef_serving': 27.0,
    'pork_serving': 12.1,
    'chicken_serving': 6.9,
    'fish_serving': 4.6,
    'vegetarian_meal': 1.9,
    'vegan_meal': 0.9,
    'organic_waste_kg': -0.5, // Negative because composting saves CO2
    'recycling_kg': -0.3,
    'landfill_waste_kg': 0.8,
  };

  // Carbon Categories
  static const List<String> carbonCategories = [
    'transport',
    'energy',
    'food',
    'waste',
  ];

  // Transport Sub-types
  static const Map<String, List<String>> transportSubTypes = {
    'transport': ['car_km', 'bus_km', 'train_km', 'bike_km', 'walk_km'],
  };

  // Energy Sub-types
  static const Map<String, List<String>> energySubTypes = {
    'energy': ['electricity_kwh', 'gas_m3', 'heating_kwh'],
  };

  // Food Sub-types
  static const Map<String, List<String>> foodSubTypes = {
    'food': ['beef_serving', 'pork_serving', 'chicken_serving', 'fish_serving', 'vegetarian_meal', 'vegan_meal'],
  };

  // Waste Sub-types
  static const Map<String, List<String>> wasteSubTypes = {
    'waste': ['organic_waste_kg', 'recycling_kg', 'landfill_waste_kg'],
  };

  // Unit Labels
  static const Map<String, String> unitLabels = {
    'car_km': 'km',
    'bus_km': 'km',
    'train_km': 'km',
    'bike_km': 'km',
    'walk_km': 'km',
    'electricity_kwh': 'kWh',
    'gas_m3': 'm³',
    'heating_kwh': 'kWh',
    'beef_serving': 'servings',
    'pork_serving': 'servings',
    'chicken_serving': 'servings',
    'fish_serving': 'servings',
    'vegetarian_meal': 'meals',
    'vegan_meal': 'meals',
    'organic_waste_kg': 'kg',
    'recycling_kg': 'kg',
    'landfill_waste_kg': 'kg',
  };

  // Text Size Options
  static const Map<String, double> textSizeMultipliers = {
    'small': 0.85,
    'normal': 1.0,
    'large': 1.2,
    'xlarge': 1.4,
  };

  // Challenge Frequencies
  static const List<String> challengeFrequencies = [
    'daily',
    'weekly',
    'monthly',
  ];

  // Demo Image URLs
  static const List<String> demoImageUrls = [
    'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1569163139394-de4e4f43e4e3?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1574263867128-a3d5c1b1deaa?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511593358241-7eea1f3c84e5?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?q=80&w=1000&auto=format&fit=crop',
  ];
}
