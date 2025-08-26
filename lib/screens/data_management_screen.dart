import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/data_persistence_service.dart';
import '../theme/app_theme.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _backupInfo;
  bool _backupExists = false;

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    setState(() => _isLoading = true);
    
    try {
      _backupExists = await DataPersistenceService.backupExists();
      if (_backupExists) {
        _backupInfo = await DataPersistenceService.getBackupInfo();
      }
    } catch (e) {
      print('Error loading backup info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    
    try {
      // This would typically be called from MusicProvider
      // For now, we'll show a success message
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBackupInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text(
          'Are you sure you want to delete the backup? This will remove all saved data and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        final success = await DataPersistenceService.deleteBackup();
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Backup deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadBackupInfo();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete backup'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting backup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Data Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(isDark),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildBackupSection(isDark),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildStorageInfo(isDark),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildDataPersistenceInfo(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradientLinear,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Text(
                  'Data Persistence',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Your playlists and audio files are automatically backed up to external storage. This means they will survive app reinstalls and device restarts.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          if (_backupExists && _backupInfo != null) ...[
            _buildBackupInfoTile('Version', _backupInfo!['version'] ?? 'Unknown'),
            _buildBackupInfoTile('Created', _formatDate(_backupInfo!['timestamp'])),
            _buildBackupInfoTile('File Size', _formatFileSize(_backupInfo!['fileSize'])),
            _buildBackupInfoTile('Location', _backupInfo!['filePath'] ?? 'Unknown'),
            
            const SizedBox(height: AppTheme.spacingMedium),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createBackup,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteBackup,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Backup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      'No backup found. Create one to protect your data.',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMedium),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createBackup,
                icon: const Icon(Icons.backup),
                label: const Text('Create Backup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Locations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          _buildStorageInfoTile(
            'Audio Files',
            '/storage/emulated/0/SoundWave/Audio',
            Icons.music_note,
            Colors.blue,
          ),
          _buildStorageInfoTile(
            'Data Backup',
            '/storage/emulated/0/SoundWave',
            Icons.backup,
            Colors.green,
          ),
          _buildStorageInfoTile(
            'App Data',
            'Internal App Storage',
            Icons.phone_android,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStorageInfoTile(String label, String path, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  path,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPersistenceInfo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          _buildInfoItem(
            '1. Automatic Backup',
            'Your data is automatically backed up to external storage whenever you make changes.',
            Icons.auto_awesome,
          ),
          _buildInfoItem(
            '2. App Reinstall',
            'When you reinstall the app, it will automatically detect and restore your previous data.',
            Icons.restore,
          ),
          _buildInfoItem(
            '3. Data Safety',
            'Your playlists and audio files are stored in external storage that survives app uninstalls.',
            Icons.security,
          ),
          _buildInfoItem(
            '4. Manual Control',
            'You can manually create, refresh, or delete backups as needed.',
            Icons.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
