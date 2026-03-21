import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../splash_screen.dart';
import 'create_report_screen.dart';
import 'all_reports_screen.dart';
import '../admin/admin_dashboard.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    // Load reports and read state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      reportProvider.loadReports();
      if (authProvider.firebaseUser != null) {
        reportProvider.loadMyReports(authProvider.firebaseUser!.uid);
        reportProvider.loadReadReports(authProvider.firebaseUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final userId = authProvider.firebaseUser?.uid ?? '';

    final screens = [
      const CreateReportScreen(),
      const AllReportsScreen(),
      if (isAdmin) const AdminDashboard(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.cardGradient,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${authProvider.userModel?.firstName.isNotEmpty == true ? authProvider.userModel!.firstName[0] : ''}${authProvider.userModel?.lastName.isNotEmpty == true ? authProvider.userModel!.lastName[0] : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${authProvider.userModel?.firstName ?? 'User'}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            isAdmin
                                ? 'Admin • Command Staff Notification'
                                : 'Command Staff Notification',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.accentLight.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SplashScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Content Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: IndexedStack(
                      index: _currentIndex,
                      children: screens,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: screens.length < 2
          ? null
          : Container(
              decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<ReportProvider>(
          builder: (context, reportProvider, _) {
            final unreadCount = reportProvider.getUnreadCount(userId);

            return NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              backgroundColor: AppColors.white,
              indicatorColor: AppColors.primary.withValues(alpha: 0.1),
              height: 70,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                // Tab 1: Create Report
                const NavigationDestination(
                  icon: Icon(Icons.edit_document, color: AppColors.grey),
                  selectedIcon: Icon(Icons.edit_document, color: AppColors.primary),
                  label: 'Create Report',
                ),
                // Tab 2: All Reports (with unread badge)
                NavigationDestination(
                    icon: Badge(
                      isLabelVisible: unreadCount > 0,
                      backgroundColor: AppColors.error,
                      label: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Icon(Icons.folder_rounded, color: AppColors.grey),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: unreadCount > 0,
                      backgroundColor: AppColors.error,
                      label: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Icon(Icons.folder_rounded, color: AppColors.primary),
                    ),
                    label: 'All Reports',
                  ),
                // Tab 3: Admin (only for admins)
                if (isAdmin)
                  const NavigationDestination(
                    icon: Icon(Icons.admin_panel_settings_rounded,
                        color: AppColors.grey),
                    selectedIcon: Icon(Icons.admin_panel_settings_rounded,
                        color: AppColors.primary),
                    label: 'Admin',
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
