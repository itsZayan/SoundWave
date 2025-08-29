import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/persistent_storage_service.dart';
import '../services/app_uninstall_handler.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _preserveData = true;
  bool _isLoading = true;
  Map<String, dynamic> _storageInfo = {};
  Map<String, dynamic> _dataStatus = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final uninstallHandler = AppUninstallHandler();
      final persistentStorage = PersistentStorageService();
      
      await persistentStorage.initialize();
      
      _preserveData = await uninstallHandler.shouldPreserveData();
      _storageInfo = persistentStorage.getStorageInfo();
      _dataStatus = await uninstallHandler.getDataPreservationStatus();
      
    } catch (e) {
      print('❌ Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDataPreservation(bool preserve) async {
    try {
      final uninstallHandler = AppUninstallHandler();
      await uninstallHandler.setDataPreservation(preserve);
      
      setState(() => _preserveData = preserve);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              preserve 
                ? 'Your music and playlists will be preserved when uninstalling'
                : 'All app data will be deleted when uninstalling',
            ),
            backgroundColor: preserve ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating data preservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data Preservation Section
                  _buildSectionHeader(
                    icon: Icons.storage,
                    title: 'Data & Storage',
                    subtitle: 'Manage how your data is handled',
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Data Preservation Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.backup,
                                color: Colors.blue[700],
                                size: 24,
                              ),
                              const SizedBox(width: AppTheme.spacingMedium),
                              const Expanded(
                                child: Text(
                                  'Preserve App Data',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _preserveData,
                                onChanged: _updateDataPreservation,
                                activeColor: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            _preserveData
                                ? 'When you uninstall the app, your music, playlists, and settings will be preserved. You can reinstall anytime to access them.'
                                : 'When you uninstall the app, all data will be deleted permanently.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Storage Information Section
                  _buildSectionHeader(
                    icon: Icons.info_outline,
                    title: 'Storage Information',
                    subtitle: 'Details about your app data storage',
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Storage Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStorageInfoRow(
                            'Storage Type',
                            _storageInfo['isExternalStorage'] == true 
                                ? 'External Storage (Survives Uninstall)'
                                : 'App Documents (Deleted on Uninstall)',
                            _storageInfo['isExternalStorage'] == true 
                                ? Colors.green 
                                : Colors.orange,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          _buildStorageInfoRow(
                            'App Data Directory',
                            _storageInfo['appDataDir'] ?? 'Not available',
                            Colors.grey[700]!,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          _buildStorageInfoRow(
                            'Downloads Directory',
                            _storageInfo['downloadsDir'] ?? 'Not available',
                            Colors.grey[700]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // App Status Section
                  _buildSectionHeader(
                    icon: Icons.app_settings_alt,
                    title: 'App Status',
                    subtitle: 'Current app information and data status',
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // App Status Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStorageInfoRow(
                            'App Version',
                            _dataStatus['appVersion'] ?? 'Unknown',
                            Colors.blue[700]!,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          _buildStorageInfoRow(
                            'Data Preservation',
                            _dataStatus['preserveData'] == true ? 'Enabled' : 'Disabled',
                            _dataStatus['preserveData'] == true ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),
                          _buildStorageInfoRow(
                            'Install Type',
                            _dataStatus['isFirstRun'] == true ? 'Fresh Install' : 'Update/Reinstall',
                            _dataStatus['isFirstRun'] == true ? Colors.orange : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Actions Section
                  _buildSectionHeader(
                    icon: Icons.build,
                    title: 'Actions',
                    subtitle: 'Manage your app data',
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Actions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.refresh,
                            color: Colors.blue[700],
                          ),
                          title: const Text('Refresh Storage Info'),
                          subtitle: const Text('Update storage information'),
                          onTap: _loadSettings,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.delete_forever,
                            color: Colors.red[700],
                          ),
                          title: const Text('Clear All Data'),
                          subtitle: const Text('Delete all app data (irreversible)'),
                          onTap: _showClearDataDialog,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingExtraLarge),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue[700],
          size: 24,
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageInfoRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showClearDataDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Clear All Data?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'This will permanently delete all your music, playlists, and app settings. This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _clearAllData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Clear All Data',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData() async {
    try {
      final persistentStorage = PersistentStorageService();
      await persistentStorage.clearAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All app data has been cleared'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload settings to reflect changes
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
