import 'package:flutter/material.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_repository.dart';
import 'package:x_project_flutter/core/repositories/user_data/firebase_user_data_source.dart';
import 'package:x_project_flutter/core/models/user.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<FirebaseUser> _allUsers = [];
  List<FirebaseUser> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final pseudo = user.pseudo?.toLowerCase() ?? '';
        final bio = user.bio?.toLowerCase() ?? '';
        return pseudo.contains(query) || bio.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final repo = UserRepository(userDataSource: FirebaseUserDataSource());
    final users = await repo.getAllUsers();
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF2F3336),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF71767B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Rechercher des utilisateurs...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF71767B),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      autofocus: true,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() {
                          _filteredUsers = _allUsers;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF71767B).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF71767B),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D9BF0),
                        strokeWidth: 2,
                      ),
                    )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _controller.text.isEmpty
                                    ? Icons.search_outlined
                                    : Icons.person_search_outlined,
                                color: const Color(0xFF71767B),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _controller.text.isEmpty
                                    ? 'Recherchez des utilisateurs'
                                    : 'Aucun utilisateur trouvé',
                                style: const TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _controller.text.isEmpty
                                    ? 'Tapez pour commencer votre recherche'
                                    : 'Essayez un autre terme de recherche',
                                style: const TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return UserCardWidget(
                              user: user,
                              query: _controller.text,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(userId: user.uid),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCardWidget extends StatelessWidget {
  final FirebaseUser user;
  final String query;
  final VoidCallback onTap;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF2F3336),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: (user.imagePath != null && user.imagePath!.isNotEmpty)
                      ? NetworkImage(user.imagePath!)
                      : null,
                  radius: 22,
                  backgroundColor: const Color(0xFF536471),
                  child: (user.imagePath == null || user.imagePath!.isEmpty)
                      ? const Icon(Icons.person, size: 24, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildHighlightedText(
                            user.pseudo ?? '',
                            query,
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            const TextStyle(
                              color: Color(0xFF1D9BF0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D9BF0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1D9BF0).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '@${user.pseudo?.toLowerCase() ?? ''}',
                            style: const TextStyle(
                              color: Color(0xFF1D9BF0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildHighlightedText(
                        user.bio!,
                        query,
                        const TextStyle(
                          color: Color(0xFF71767B),
                          fontSize: 14,
                        ),
                        const TextStyle(
                          color: Color(0xFF1D9BF0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D9BF0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1D9BF0).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF1D9BF0),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle, {
    int maxLines = 1,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: normalStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: normalStyle));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
} 