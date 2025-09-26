import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/responsive_grid_widget.dart';
import '../models/product_model.dart';
import '../core/responsive_layout.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  int? _minEcoScore;
  String _sortBy = 'ecoScore';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Eco Products'),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: ResponsiveLayout.getPadding(context),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search eco-friendly products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Category', _selectedCategory, _showCategoryFilter),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Eco Score', 
                  _minEcoScore != null ? '$_minEcoScore+' : null, 
                  _showEcoScoreFilter
                ),
                const SizedBox(width: 8),
                _buildSortChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, VoidCallback onTap) {
    final hasValue = value != null;
    return FilterChip(
      label: Text('$label${hasValue ? ': $value' : ''}'),
      selected: hasValue,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
    );
  }

  Widget _buildSortChip() {
    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort, size: 16),
          const SizedBox(width: 4),
          Text(_sortBy == 'ecoScore' ? 'Eco Score' : _sortBy == 'price' ? 'Price' : 'Rating'),
        ],
      ),
      onPressed: _showSortOptions,
      backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<DatabaseService>(
      builder: (context, databaseService, child) {
        final allProducts = databaseService.products;
        final filteredProducts = databaseService.searchProducts(
          _searchQuery,
          category: _selectedCategory,
          minEcoScore: _minEcoScore,
        );

        // Sort products
        filteredProducts.sort((a, b) {
          switch (_sortBy) {
            case 'ecoScore':
              return b.ecoScore.compareTo(a.ecoScore);
            case 'price':
              final priceA = a.price ?? double.infinity;
              final priceB = b.price ?? double.infinity;
              return priceA.compareTo(priceB);
            case 'rating':
              return b.rating.compareTo(a.rating);
            default:
              return 0;
          }
        });

        if (filteredProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty || _selectedCategory != null || _minEcoScore != null
                      ? 'No products found'
                      : 'No products available',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isNotEmpty || _selectedCategory != null || _minEcoScore != null) ...[
                  Text(
                    'Try adjusting your search or filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear All Filters'),
                  ),
                ],
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Results count
              Text(
                '${filteredProducts.length} product${filteredProducts.length != 1 ? 's' : ''} found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Product grid
              ResponsiveGridWidget(
                children: filteredProducts.map((product) => 
                  ProductCardWidget(
                    product: product,
                    onTap: () => _showProductDetails(product),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryFilter() {
    final categories = ['personal_care', 'kitchen', 'bags', 'electronics', 'home'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                title: const Text('All Categories'),
                leading: _selectedCategory == null 
                    ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                    : const SizedBox(width: 24),
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                  Navigator.pop(context);
                },
              ),
              
              ...categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ListTile(
                  title: Text(_formatCategoryName(category)),
                  leading: isSelected 
                      ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                      : const SizedBox(width: 24),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEcoScoreFilter() {
    final scores = [50, 60, 70, 80, 90];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Minimum Eco Score',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                title: const Text('Any Score'),
                leading: _minEcoScore == null 
                    ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                    : const SizedBox(width: 24),
                onTap: () {
                  setState(() {
                    _minEcoScore = null;
                  });
                  Navigator.pop(context);
                },
              ),
              
              ...scores.map((score) {
                final isSelected = _minEcoScore == score;
                return ListTile(
                  title: Text('$score+ (${_getEcoScoreLabel(score)})'),
                  leading: isSelected 
                      ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                      : const SizedBox(width: 24),
                  onTap: () {
                    setState(() {
                      _minEcoScore = score;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    final options = [
      {'key': 'ecoScore', 'label': 'Eco Score (High to Low)'},
      {'key': 'rating', 'label': 'Rating (High to Low)'},
      {'key': 'price', 'label': 'Price (Low to High)'},
    ];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort Products',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ...options.map((option) {
                final isSelected = _sortBy == option['key'];
                return ListTile(
                  title: Text(option['label']!),
                  leading: isSelected 
                      ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                      : const SizedBox(width: 24),
                  onTap: () {
                    setState(() {
                      _sortBy = option['key']!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Product Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getEcoScoreColor(product.ecoScore).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Eco Score: ${product.ecoScore}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getEcoScoreColor(product.ecoScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Price and Rating
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _launchSupplierUrl(product.supplierUrl),
                        child: const Text('View Product'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _minEcoScore = null;
      _sortBy = 'ecoScore';
    });
  }

  String _formatCategoryName(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _getEcoScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Poor';
  }

  Color _getEcoScoreColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFEB3B);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFFF5722);
  }

  Future<void> _launchSupplierUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open product link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
