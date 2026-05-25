import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResponsiveLayout extends StatefulWidget {
  final List<Widget> screens;
  final List<String> tabNames;
  final Widget? headerActions;

  const ResponsiveLayout({
    super.key,
    required this.screens,
    required this.tabNames,
    this.headerActions,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  int _currentIndex = 0;

  final List<IconData> _navIcons = [
    LucideIcons.house,
    LucideIcons.bookOpen,
    LucideIcons.pencil,
    LucideIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          // --- DESKTOP VIEW (Top Navigation Header) ---
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).cardColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(LucideIcons.graduationCap, color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'SANT ACADEMY',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(width: 40),
                  // Navigation Links
                  ...List.generate(widget.tabNames.length, (index) {
                    final isSelected = _currentIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextButton(
                        onPressed: () => setState(() => _currentIndex = index),
                        style: TextButton.styleFrom(
                          foregroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        child: Text(
                          widget.tabNames[index].toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              actions: widget.headerActions != null ? [widget.headerActions!] : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                  height: 1,
                ),
              ),
            ),
            body: widget.screens[_currentIndex],
          );
        } else if (constraints.maxWidth >= 640) {
          // --- TABLET VIEW (Left Navigation Rail) ---
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Icon(
                      LucideIcons.graduationCap,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  destinations: List.generate(widget.tabNames.length, (index) {
                    return NavigationRailDestination(
                      icon: Icon(_navIcons[index]),
                      selectedIcon: Icon(_navIcons[index], color: Theme.of(context).colorScheme.primary),
                      label: Text(
                        widget.tabNames[index],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                ),
                Expanded(
                  child: widget.screens[_currentIndex],
                ),
              ],
            ),
          );
        } else {
          // --- MOBILE VIEW (Persistent Bottom Bar + Dense Layout) ---
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(LucideIcons.graduationCap, color: Colors.blue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'SANT ACADEMY',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
              actions: widget.headerActions != null ? [widget.headerActions!] : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Theme.of(context).dividerColor.withOpacity(0.05),
                  height: 1,
                ),
              ),
            ),
            body: widget.screens[_currentIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).cardColor,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: List.generate(widget.tabNames.length, (index) {
                  return BottomNavigationBarItem(
                    icon: Icon(_navIcons[index], size: 20),
                    activeIcon: Icon(_navIcons[index], size: 20),
                    label: widget.tabNames[index],
                  );
                }),
              ),
            ),
          );
        }
      },
    );
  }
}
