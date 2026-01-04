import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme_constants.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _recentSearches = [
    {'type': 'user', 'name': 'john_doe', 'avatar': null},
    {'type': 'user', 'name': 'jane_smith', 'avatar': null},
    {'type': 'hashtag', 'name': '#flutter', 'count': '1.2M posts'},
    {'type': 'hashtag', 'name': '#dart', 'count': '850K posts'},
  ];

  final List<Map<String, dynamic>> _searchResults = [
    {
      'type': 'user',
      'name': 'john_doe',
      'fullName': 'John Doe',
      'avatar': null,
      'isVerified': true,
      'followers': '1.2M'
    },
    {
      'type': 'user',
      'name': 'jane_smith',
      'fullName': 'Jane Smith',
      'avatar': null,
      'isVerified': false,
      'followers': '850K'
    },
    {
      'type': 'hashtag',
      'name': '#flutter',
      'count': '1.2M posts'
    },
    {
      'type': 'hashtag',
      'name': '#dart',
      'count': '850K posts'
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    // TODO: Implement actual search API call
    // ref.read(searchProvider.notifier).search(query);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search users, posts, hashtags...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSearching ? _buildSearchResults() : _buildRecentSearches(),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Clear recent searches
              },
              child: const Text('Clear all'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ..._recentSearches.map((item) => _buildSearchItem(item, isRecent: true)),
      ],
    );
  }

  Widget _buildSearchResults() {
    final filteredResults = _searchResults.where((item) {
      final name = item['name'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    if (filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        return _buildSearchItem(filteredResults[index]);
      },
    );
  }

  Widget _buildSearchItem(Map<String, dynamic> item, {bool isRecent = false}) {
    if (item['type'] == 'user') {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            color: Colors.grey[600],
          ),
        ),
        title: Row(
          children: [
            Text(
              item['name'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (item['isVerified'] == true) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.verified,
                size: 16,
                color: Colors.blue,
              ),
            ],
          ],
        ),
        subtitle: item['fullName'] != null
            ? Text('${item['fullName']} • ${item['followers']} followers')
            : Text('${item['followers']} followers'),
        trailing: isRecent
            ? IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  // TODO: Remove from recent searches
                },
              )
            : null,
        onTap: () {
          // TODO: Navigate to user profile
        },
      );
    } else if (item['type'] == 'hashtag') {
      return ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          child: const Icon(
            Icons.tag,
            color: Colors.grey,
          ),
        ),
        title: Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(item['count']),
        trailing: isRecent
            ? IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  // TODO: Remove from recent searches
                },
              )
            : null,
        onTap: () {
          // TODO: Navigate to hashtag page
        },
      );
    }

    return const SizedBox.shrink();
  }
}
