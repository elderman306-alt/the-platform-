import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GamingScreen extends StatelessWidget {
  const GamingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gaming Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Games Played', '42'),
                    _buildStatItem('Win Rate', '68%'),
                    _buildStatItem('Rank', 'Diamond'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Featured Games
            const Text(
              'Featured Games',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFeaturedGame('P2P Chess', 'Strategy', Icons.grid_3x3),
                  const SizedBox(width: 12),
                  _buildFeaturedGame('Mesh Battles', 'Action', Icons.sports_martial_arts),
                  const SizedBox(width: 12),
                  _buildFeaturedGame('Crypto Races', 'Racing', Icons.directions_car),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Game Categories
            const Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryCard('Strategy', Icons.psychology, '12 games'),
                _buildCategoryCard('Action', Icons.sports_martial_arts, '8 games'),
                _buildCategoryCard('Puzzle', Icons.extension, '15 games'),
                _buildCategoryCard('Card', Icons.style, '6 games'),
              ],
            ),
            const SizedBox(height: 24),
            // Tournaments
            const Text(
              'Active Tournaments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTournamentCard('Weekly Chess Cup', '\$500 Prize', '24/32 players'),
            _buildTournamentCard('Battle Royale', '\$1,000 Prize', '8/100 players'),
            const SizedBox(height: 24),
            // Leaderboard
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLeaderboardTile(1, 'PlayerOne', '2500 pts'),
            _buildLeaderboardTile(2, 'CryptoGamer', '2350 pts'),
            _buildLeaderboardTile(3, 'P2P_Master', '2280 pts'),
            _buildLeaderboardTile(4, 'MeshKing', '2150 pts'),
            _buildLeaderboardTile(5, 'BlockchainPro', '2020 pts'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedGame(String title, String category, IconData icon) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              count,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard(String title, String prize, String players) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.emoji_events,
            color: AppTheme.warningColor,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          prize,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            players,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTile(int rank, String name, String score) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: rank == 1
                ? AppTheme.warningColor
                : rank == 2
                    ? AppTheme.textSecondary
                    : rank == 3
                        ? AppTheme.warningColor.withOpacity(0.7)
                        : AppTheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? AppTheme.backgroundColor : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(name),
        trailing: Text(
          score,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}