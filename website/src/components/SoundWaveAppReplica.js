import React, { useState, useEffect } from 'react';
import { 
  Home, 
  Search, 
  Music, 
  List,
  Play,
  Pause,
  SkipBack,
  SkipForward,
  Download,
  MoreVertical,
  Plus,
  Shuffle,
  Repeat,
  Heart,
  Battery,
  Wifi,
  Signal,
  Sun,
  Moon,
  RefreshCw
} from 'lucide-react';
import './SoundWaveAppReplica.css';

const SoundWaveAppReplica = () => {
  const [currentScreen, setCurrentScreen] = useState(0); // 0: Home, 1: Search, 2: Library, 3: Playlists
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentSong, setCurrentSong] = useState(null);

  // Auto-cycle through screens every 4 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentScreen(prev => (prev + 1) % 4);
    }, 4000);

    return () => clearInterval(interval);
  }, []);

  // Sample data exactly like your Flutter app
  const recentMusic = [
    {
      id: '1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      thumbnail: 'https://via.placeholder.com/60x60/8E44AD/FFFFFF?text=BL',
      duration: '3:20',
      addedAt: '2024-01-15T10:30:00Z'
    },
    {
      id: '2',
      title: 'Watermelon Sugar',
      artist: 'Harry Styles',
      thumbnail: 'https://via.placeholder.com/60x60/3498DB/FFFFFF?text=WS',
      duration: '2:54',
      addedAt: '2024-01-14T14:20:00Z'
    },
    {
      id: '3',
      title: 'Levitating',
      artist: 'Dua Lipa',
      thumbnail: 'https://via.placeholder.com/60x60/2ECC71/FFFFFF?text=LV',
      duration: '3:23',
      addedAt: '2024-01-13T09:15:00Z'
    }
  ];

  const trendingVideos = [
    {
      id: '4',
      title: 'As It Was',
      channel: 'Harry Styles',
      thumbnail: 'https://via.placeholder.com/60x60/E74C3C/FFFFFF?text=AW',
      viewCount: 1200000000,
      duration: '2:47'
    },
    {
      id: '5',
      title: 'Heat Waves',
      channel: 'Glass Animals',
      thumbnail: 'https://via.placeholder.com/60x60/F39C12/FFFFFF?text=HW',
      viewCount: 950000000,
      duration: '3:58'
    }
  ];

  const downloadedFiles = [
    {
      id: '1',
      title: 'Blinding Lights',
      author: 'The Weeknd',
      thumbnail: 'https://via.placeholder.com/60x60/8E44AD/FFFFFF?text=BL',
      fileType: 'audio',
      duration: 200
    },
    {
      id: '2',
      title: 'Watermelon Sugar',
      author: 'Harry Styles',
      thumbnail: 'https://via.placeholder.com/60x60/3498DB/FFFFFF?text=WS',
      fileType: 'audio',
      duration: 174
    },
    {
      id: '3',
      title: 'Shape of You',
      author: 'Ed Sheeran',
      thumbnail: 'https://via.placeholder.com/60x60/E74C3C/FFFFFF?text=SY',
      fileType: 'video',
      duration: 263
    }
  ];

  const playlists = [
    { id: '1', name: 'My Favorites', songCount: 25 },
    { id: '2', name: 'Workout Mix', songCount: 18 },
    { id: '3', name: 'Chill Vibes', songCount: 32 }
  ];

  const handlePlayPause = (song) => {
    if (currentSong?.id === song.id) {
      setIsPlaying(!isPlaying);
    } else {
      setCurrentSong(song);
      setIsPlaying(true);
    }
  };

  const formatViewCount = (count) => {
    if (count >= 1000000000) {
      return (count / 1000000000).toFixed(1) + 'B';
    } else if (count >= 1000000) {
      return (count / 1000000).toFixed(1) + 'M';
    } else if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'K';
    }
    return count.toString();
  };

  // Navigation items exactly like your Flutter app
  const navigationItems = [
    { icon: Home, label: 'Home', color: '#8E44AD' },
    { icon: Search, label: 'Search', color: '#3498DB' },
    { icon: Music, label: 'Library', color: '#2ECC71' },
    { icon: List, label: 'Playlists', color: '#F39C12' }
  ];

  const getScreenTitle = () => {
    switch (currentScreen) {
      case 0: return 'Home';
      case 1: return 'Search';
      case 2: return 'Library';
      case 3: return 'Playlists';
      default: return 'SoundWave';
    }
  };

  // Home Screen - exact replica
  const HomeScreen = () => (
    <div className="screen-content">
      <div className="welcome-section">
        <h2 className="welcome-title">Welcome Back</h2>
        <p className="welcome-subtitle">Let the music play!</p>
      </div>

      <div className="quick-actions-grid">
        <div className="quick-action">
          <div className="quick-action-icon primary">
            <Plus size={32} />
          </div>
          <span>Add Music</span>
        </div>
        <div className="quick-action">
          <div className="quick-action-icon secondary">
            <List size={32} />
          </div>
          <span>Playlists</span>
        </div>
        <div className="quick-action">
          <div className="quick-action-icon success">
            <Shuffle size={32} />
          </div>
          <span>Shuffle All</span>
        </div>
      </div>

      {recentMusic.length > 0 && (
        <div className="section">
          <div className="section-header">
            <h3>Recently Added</h3>
            <button className="view-all-btn">View All</button>
          </div>
          <div className="songs-list">
            {recentMusic.slice(0, 3).map((song) => (
              <div key={song.id} className="song-item">
                <div className="song-thumbnail">
                  <img src={song.thumbnail} alt={song.title} />
                  <div className="play-overlay">
                    {currentSong?.id === song.id && isPlaying ? (
                      <Pause size={20} />
                    ) : (
                      <Play size={20} />
                    )}
                  </div>
                </div>
                <div className="song-info">
                  <h4 className="song-title">{song.title}</h4>
                  <p className="song-artist">{song.artist}</p>
                </div>
                <button className="play-btn">
                  <Play size={20} />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {recentMusic.length === 0 && (
        <div className="empty-state">
          <Music size={80} className="empty-icon" />
          <h3>Your Library is Empty</h3>
          <p>Add music from YouTube to get started.</p>
          <button className="add-music-btn">
            <Plus size={20} />
            Add Music
          </button>
        </div>
      )}
    </div>
  );

  // Search Screen - exact replica
  const SearchScreen = () => (
    <div className="screen-content">
      <div className="search-container">
        <div className="search-input-wrapper">
          <Search size={20} className="search-icon" />
          <input
            type="text"
            placeholder="Search for music on YouTube..."
            className="search-input"
          />
          <button className="search-btn">
            <Search size={20} />
          </button>
        </div>
      </div>

      <div className="section">
        <h3 className="section-title">Trending Music</h3>
        <div className="trending-list">
          {trendingVideos.map((video) => (
            <div key={video.id} className="video-item">
              <div className="video-thumbnail">
                <img src={video.thumbnail} alt={video.title} />
              </div>
              <div className="video-info">
                <h4 className="video-title">{video.title}</h4>
                <p className="video-channel">{video.channel}</p>
                <p className="video-views">{formatViewCount(video.viewCount)} views</p>
              </div>
              <div className="video-actions">
                <button className="play-video-btn">
                  <Play size={18} />
                </button>
                <button className="download-video-btn">
                  <Download size={18} />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  // Library Screen - exact replica
  const LibraryScreen = () => (
    <div className="screen-content">
      <div className="section">
        <div className="library-stats">
          <div className="stat">
            <span className="stat-number">{downloadedFiles.length}</span>
            <span className="stat-label">Songs</span>
          </div>
          <div className="stat">
            <span className="stat-number">{playlists.length}</span>
            <span className="stat-label">Playlists</span>
          </div>
          <div className="stat">
            <span className="stat-number">12</span>
            <span className="stat-label">Artists</span>
          </div>
        </div>

        {downloadedFiles.length > 0 && (
          <>
            <h4 className="downloaded-title">Downloaded Songs</h4>
            <div className="downloaded-songs">
              {downloadedFiles.map((file) => (
                <div key={file.id} className="library-song">
                  <img src={file.thumbnail} alt={file.title} />
                  <div className="song-details">
                    <h5>{file.title}</h5>
                    <p>{file.author}</p>
                    <div className="song-meta">
                      <Music size={12} />
                      <span>{file.fileType === 'audio' ? 'Audio' : 'Video'}</span>
                    </div>
                  </div>
                  <button className="play-btn">
                    {currentSong?.id === file.id && isPlaying ? (
                      <Pause size={20} />
                    ) : (
                      <Play size={20} />
                    )}
                  </button>
                </div>
              ))}
            </div>
          </>
        )}

        {downloadedFiles.length === 0 && (
          <div className="empty-state">
            <Music size={64} className="empty-icon" />
            <h3>No downloaded music</h3>
            <p>Download music from the search tab to listen offline</p>
          </div>
        )}
      </div>
    </div>
  );

  // Playlists Screen - exact replica
  const PlaylistsScreen = () => (
    <div className="screen-content">
      <div className="create-playlist-card">
        <div className="create-playlist-icon">
          <Plus size={24} />
        </div>
        <div className="create-playlist-info">
          <h4>Create playlist</h4>
          <p>Make your own mix</p>
        </div>
      </div>

      <div className="playlists-grid">
        {playlists.map((playlist) => (
          <div key={playlist.id} className="playlist-item">
            <div className="playlist-thumbnail">
              <Music size={30} />
            </div>
            <div className="playlist-info">
              <h4 className="playlist-name">{playlist.name}</h4>
              <p className="playlist-count">{playlist.songCount} songs</p>
            </div>
            <button className="playlist-menu-btn">
              <MoreVertical size={16} />
            </button>
          </div>
        ))}
      </div>

      {playlists.length === 0 && (
        <div className="empty-state">
          <Music size={64} className="empty-icon" />
          <h3>No playlists yet</h3>
          <p>Tap the + button to create your first playlist</p>
        </div>
      )}
    </div>
  );

  const renderCurrentScreen = () => {
    switch (currentScreen) {
      case 0: return <HomeScreen />;
      case 1: return <SearchScreen />;
      case 2: return <LibraryScreen />;
      case 3: return <PlaylistsScreen />;
      default: return <HomeScreen />;
    }
  };

  return (
    <div className="soundwave-app-replica">
      <div className={`app-frame ${isDarkMode ? 'dark' : 'light'}`}>
        <div className="app-screen">
          
          {/* Status Bar */}
          <div className="status-bar">
            <div className="status-time">9:41</div>
            <div className="status-icons">
              <Signal size={14} />
              <Wifi size={14} />
              <Battery size={14} />
              <span>100%</span>
            </div>
          </div>

          {/* App Bar */}
          <div className="app-bar">
            <div className="app-brand">
              <img 
                src="/soundwave-icon.jpg?v=27px" 
                alt="SoundWave" 
                style={{width: '27px', height: '27px', borderRadius: '5px', objectFit: 'cover', marginRight: '10px'}} 
              />
              <h1 className="app-title">{getScreenTitle()}</h1>
            </div>
            <button className="theme-toggle-btn" onClick={() => setIsDarkMode(!isDarkMode)}>
              {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
            </button>
          </div>

          {/* Main Content */}
          <div className="main-content">
            <div key={currentScreen} className="screen-wrapper">
              {renderCurrentScreen()}
            </div>

            {/* Bottom Music Player */}
            {currentSong && (
              <div className="bottom-music-player">
                <div className="mini-progress" style={{ width: '45%' }} />
                <div className="player-content">
                  <div className="mini-thumbnail">
                    <img src={currentSong.thumbnail} alt={currentSong.title} />
                  </div>
                  <div className="mini-info">
                    <h5 className="mini-title">{currentSong.title}</h5>
                    <p className="mini-artist">{currentSong.artist || currentSong.author}</p>
                  </div>
                  <button className="mini-play-btn" onClick={() => setIsPlaying(!isPlaying)}>
                    {isPlaying ? <Pause size={20} /> : <Play size={20} />}
                  </button>
                </div>
              </div>
            )}

            {/* Bottom Navigation */}
            <div className="bottom-navigation">
              {navigationItems.map((item, index) => (
                <div
                  key={index}
                  className={`nav-item ${currentScreen === index ? 'active' : ''}`}
                  style={currentScreen === index ? { color: item.color } : {}}
                >
                  <item.icon size={24} />
                  <span>{item.label}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SoundWaveAppReplica;
