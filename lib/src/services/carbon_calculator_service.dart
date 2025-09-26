import '../core/constants.dart';
import '../models/carbon_entry_model.dart';

class CarbonCalculatorService {
  static double calculateCO2e(String subType, double quantity) {
    final emissionFactor = AppConstants.emissionFactors[subType] ?? 0.0;
    return quantity * emissionFactor;
  }

  static String getCalculationFormula(String subType, double quantity) {
    final emissionFactor = AppConstants.emissionFactors[subType] ?? 0.0;
    final co2e = calculateCO2e(subType, quantity);
    final unit = AppConstants.unitLabels[subType] ?? '';
    
    return '${quantity.toStringAsFixed(1)} $unit × ${emissionFactor.toStringAsFixed(3)} = ${co2e.toStringAsFixed(2)} kg CO₂e';
  }

  static Map<String, double> getCategorySummary(List<CarbonEntryModel> entries) {
    final summary = <String, double>{};
    
    for (final entry in entries) {
      summary[entry.category] = (summary[entry.category] ?? 0.0) + entry.co2eKg;
    }
    
    return summary;
  }

  static List<MapEntry<DateTime, double>> getDailySummary(List<CarbonEntryModel> entries) {
    final dailyMap = <DateTime, double>{};
    
    for (final entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyMap[date] = (dailyMap[date] ?? 0.0) + entry.co2eKg;
    }
    
    final sortedEntries = dailyMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries;
  }

  static double getTotalCO2e(List<CarbonEntryModel> entries) {
    return entries.fold<double>(0.0, (sum, entry) => sum + entry.co2eKg);
  }

  static double getAverageDaily(List<CarbonEntryModel> entries) {
    if (entries.isEmpty) return 0.0;
    
    final dailySummary = getDailySummary(entries);
    if (dailySummary.isEmpty) return 0.0;
    
    final totalCO2e = dailySummary.fold<double>(0.0, (sum, entry) => sum + entry.value);
    return totalCO2e / dailySummary.length;
  }

  static String getRecommendation(String category, double co2eKg) {
    switch (category) {
      case 'transport':
        if (co2eKg > 10) {
          return 'Consider using public transport, cycling, or walking for shorter trips.';
        } else if (co2eKg > 5) {
          return 'Good job! Try combining trips or carpooling to reduce emissions further.';
        } else {
          return 'Excellent! You\'re using low-carbon transport options.';
        }
      
      case 'energy':
        if (co2eKg > 15) {
          return 'Try reducing energy consumption by unplugging devices and using LED bulbs.';
        } else if (co2eKg > 8) {
          return 'Good progress! Consider switching to renewable energy sources.';
        } else {
          return 'Great energy efficiency! Keep up the good work.';
        }
      
      case 'food':
        if (co2eKg > 20) {
          return 'Consider reducing meat consumption and choosing local, seasonal produce.';
        } else if (co2eKg > 10) {
          return 'Good choices! Try incorporating more plant-based meals.';
        } else {
          return 'Excellent food choices with low carbon impact!';
        }
      
      case 'waste':
        if (co2eKg > 2) {
          return 'Focus on reducing waste and increasing recycling and composting.';
        } else if (co2eKg > 0) {
          return 'Good waste management! Consider composting organic waste.';
        } else {
          return 'Amazing! Your waste practices are helping the planet.';
        }
      
      default:
        return 'Keep tracking your activities to understand your environmental impact.';
    }
  }
}
