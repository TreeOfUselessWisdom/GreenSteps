import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/responsive_layout.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showUserName;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showUserName = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showUserName) _buildUserNameWidget(context),
        ...?actions,
      ],
    );
  }

  Widget _buildUserNameWidget(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        if (user == null) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                backgroundColor: Colors.white,
                child: user.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              if (ResponsiveLayout.getContentWidth(context) > 400)
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
