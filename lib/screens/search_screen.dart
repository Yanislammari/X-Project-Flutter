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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Rechercher un utilisateur...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
              ? const Center(child: Text('Aucun utilisateur trouvé', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return UserCardWidget(
                      user: user,
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
    );
  }
}

class UserCardWidget extends StatelessWidget {
  final FirebaseUser user;
  final VoidCallback onTap;

  const UserCardWidget({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onTap,
                child: CircleAvatar(
                  backgroundImage: (user.imagePath != null && user.imagePath!.isNotEmpty)
                      ? NetworkImage(user.imagePath!)
                      : null,
                  radius: 28,
                  backgroundColor: Colors.grey[900],
                  child: (user.imagePath == null || user.imagePath!.isEmpty)
                      ? const Icon(Icons.person, size: 28, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.pseudo ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 