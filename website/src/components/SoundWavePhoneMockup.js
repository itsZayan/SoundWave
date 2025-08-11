import React, { useState, useEffect } from 'react';
import { 
  Home, 
  Search, 
  Music2, 
  Play, 
  Pause, 
  Download,
  Plus,
  MoreVertical,
  Settings,
  Sun,
  Moon,
  PlayCircle,
  SkipBack,
  SkipForward,
  Shuffle,
  Repeat,
  Volume2,
  Heart,
  ChevronDown,
  Signal,
  Wifi,
  Battery,
  CheckCircle,
  List
} from 'lucide-react';
import './SoundWavePhoneMockup.css';

const SoundWavePhoneMockup = () => {
  const [currentScreen, setCurrentScreen] = useState(0); // 0: Home, 1: Search, 2: Library, 3: Playlists
  const [isDarkMode, setIsDarkMode] = useState(true);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentSong, setCurrentSong] = useState(null);
  const [progress, setProgress] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [showTrending, setShowTrending] = useState(true);

  // Sample data matching your Flutter app
  const recentMusic = [
    {
      id: '1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      thumbnail: '/api/placeholder/60/60?text=BL',
      duration: '3:20',
      addedAt: '2024-01-15T10:30:00Z'
    },
    {
      id: '2', 
      title: 'Watermelon Sugar',
      artist: 'Harry Styles',
      thumbnail: '/api/placeholder/60/60?text=WS',
      duration: '2:54',
      addedAt: '2024-01-14T14:20:00Z'
    },
    {
      id: '3',
      title: 'Levitating',
      artist: 'Dua Lipa',
      thumbnail: '/api/placeholder/60/60?text=LE', 
      duration: '3:23',
      addedAt: '2024-01-13T09:15:00Z'
    }
  ];

  const trendingVideos = [
    {
      id: '4',
      title: 'As It Was',
      artist: 'Harry Styles',
      channel: 'Harry Styles',
      thumbnail: '/api/placeholder/60/60?text=AW',
      viewCount: 1200000000,
      duration: '2:47'
    },
    {
      id: '5',
      title: 'Heat Waves',
      artist: 'Glass Animals', 
      channel: 'Glass Animals',
      thumbnail: '/api/placeholder/60/60?text=HW',
      viewCount: 950000000,
      duration: '3:58'
    },
    {
      id: '6',
      title: 'Stay',
      artist: 'The Kid LAROI',
      channel: 'The Kid LAROI',
      thumbnail: '/api/placeholder/60/60?text=ST',
      viewCount: 800000000,
      duration: '2:21'
    }
  ];

  const playlists = [
    {
      id: '1',
      name: 'My Favorites',
      songCount: 25
    },
    {
      id: '2', 
      name: 'Workout Mix',
      songCount: 18
    },
    {
      id: '3',
      name: 'Chill Vibes',
      songCount: 32
    }
  ];

  // Auto-cycle screens every 8 seconds (slower and more natural)
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentScreen(prev => {
        const nextScreen = (prev + 1) % 4;
        
        // Simulate interactions with delays to feel more natural
        if (nextScreen === 1) {
          // Search screen - simulate typing
          setTimeout(() => {
            setSearchQuery('Harry Styles');
            setShowTrending(false);
            setIsSearching(true);
            setTimeout(() => {
              setIsSearching(false);
              setSearchResults(trendingVideos.filter(v => 
                v.artist.toLowerCase().includes('harry')
              ));
            }, 1500);
          }, 800);
        } else if (nextScreen === 2) {
          // Library - start playing music
          setTimeout(() => {
            setCurrentSong(recentMusic[0]);
            setIsPlaying(true);
            setProgress(0);
          }, 1200);
        } else if (nextScreen === 0) {
          // Reset to home
          setSearchQuery('');
          setSearchResults([]);
          setShowTrending(true);
          setIsSearching(false);
        }
        
        return nextScreen;
      });
    }, 8000); // Increased from 4000 to 8000 milliseconds

    return () => clearInterval(interval);
  }, []);

  // Progress simulation
  useEffect(() => {
    if (isPlaying && currentSong) {
      const interval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 100) {
            setIsPlaying(false);
            return 0;
          }
          return prev + 1;
        });
      }, 150);
      return () => clearInterval(interval);
    }
  }, [isPlaying, currentSong]);

  const handlePlayPause = (song) => {
    if (currentSong?.id === song.id) {
      setIsPlaying(!isPlaying);
    } else {
      setCurrentSong(song);
      setIsPlaying(true);
      setProgress(0);
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

  // Status Bar Component
  const StatusBar = () => (
    <div className="status-bar">
      <div className="status-time">9:41</div>
      <div className="status-icons">
        <Signal size={14} />
        <Wifi size={14} />
        <Battery size={14} />
        <span>100%</span>
      </div>
    </div>
  );

  // App Bar Component
  const AppBar = ({ title, onThemeToggle }) => (
    <div className="app-bar">
      <h1 className="app-title">{title}</h1>
      <button 
        className="theme-toggle-btn" 
        onClick={onThemeToggle}
        title={isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
      >
        {isDarkMode ? <Sun size={20} /> : <Moon size={20} />}
      </button>
    </div>
  );

  // Home Screen
  const HomeScreen = () => (
    <div className="screen-content">
      <div className="welcome-section">
        <h2 className="welcome-title">Welcome Back</h2>
        <p className="welcome-subtitle">Let the music play!</p>
      </div>
      
      <div className="quick-actions-grid">
        <div className="quick-action">
          <div className="quick-action-icon primary">
            <Plus size={24} />
          </div>
          <span>Add Music</span>
        </div>
        <div className="quick-action">
          <div className="quick-action-icon secondary">
            <List size={24} />
          </div>
          <span>Playlists</span>
        </div>
        <div className="quick-action">
          <div className="quick-action-icon success">
            <Shuffle size={24} />
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
              <div key={song.id} className="song-item" onClick={() => handlePlayPause(song)}>
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
          <Music2 size={64} className="empty-icon" />
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

  // Search Screen
  const SearchScreen = () => (
    <div className="screen-content">
      <div className="search-container">
        <div className="search-input-wrapper">
          <Search size={20} className="search-icon" />
          <input
            type="text"
            placeholder="Search for music on YouTube..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
          />
          <button className="search-btn">
            <Search size={20} />
          </button>
        </div>
      </div>

      {isSearching && (
        <div className="loading-container">
          <div className="loading-spinner"></div>
        </div>
      )}

      {showTrending && !isSearching && (
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
      )}

      {searchResults.length > 0 && !showTrending && !isSearching && (
        <div className="section">
          <div className="search-results-list">
            {searchResults.map((result) => (
              <div key={result.id} className="video-item">
                <div className="video-thumbnail">
                  <img src={result.thumbnail} alt={result.title} />
                </div>
                <div className="video-info">
                  <h4 className="video-title">{result.title}</h4>
                  <p className="video-channel">{result.channel}</p>
                  <p className="video-views">{formatViewCount(result.viewCount)} views</p>
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
      )}

      {searchResults.length === 0 && !showTrending && !isSearching && (
        <div className="no-results">
          <Search size={64} className="no-results-icon" />
          <h3>No results found</h3>
        </div>
      )}
    </div>
  );

  // Library Screen
  const LibraryScreen = () => (
    <div className="screen-content">
      <div className="section">
        <div className="songs-list">
          {recentMusic.map((song) => (
            <div key={song.id} className="song-item library-item" onClick={() => handlePlayPause(song)}>
              <div className="song-thumbnail">
                <img src={song.thumbnail} alt={song.title} />
              </div>
              <div className="song-info">
                <h4 className="song-title">{song.title}</h4>
                <p className="song-artist">{song.artist}</p>
                <div className="song-meta">
                  <Music2 size={12} />
                  <span>Audio</span>
                </div>
              </div>
              <button className="play-btn">
                {currentSong?.id === song.id && isPlaying ? (
                  <Pause size={20} />
                ) : (
                  <Play size={20} />
                )}
              </button>
            </div>
          ))}
        </div>
      </div>
      
      {recentMusic.length === 0 && (
        <div className="empty-state">
          <Music2 size={64} className="empty-icon" />
          <h3>No downloaded music</h3>
          <p>Download music from the search tab to listen offline</p>
        </div>
      )}
    </div>
  );

  // Playlists Screen
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
              <PlayCircle size={30} />
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
          <PlayCircle size={64} className="empty-icon" />
          <h3>No playlists yet</h3>
          <p>Tap the + button to create your first playlist</p>
        </div>
      )}
    </div>
  );

  // Bottom Music Player
  const BottomMusicPlayer = () => {
    if (!currentSong) return null;

    return (
      <div className="bottom-music-player">
        <div className="mini-progress" style={{ width: `${progress}%` }} />
        <div className="player-content">
          <div className="mini-thumbnail">
            <img src={currentSong.thumbnail} alt={currentSong.title} />
          </div>
          <div className="mini-info">
            <h5 className="mini-title">{currentSong.title}</h5>
            <p className="mini-artist">{currentSong.artist}</p>
          </div>
          <button 
            className="mini-play-btn"
            onClick={() => setIsPlaying(!isPlaying)}
          >
            {isPlaying ? <Pause size={20} /> : <Play size={20} />}
          </button>
        </div>
      </div>
    );
  };

  // Bottom Navigation
  const BottomNavigation = () => (
    <div className="bottom-navigation">
      <button 
        className={`nav-item ${currentScreen === 0 ? 'active' : ''}`}
        onClick={() => setCurrentScreen(0)}
      >
        <Home size={24} />
        <span>Home</span>
      </button>
      <button 
        className={`nav-item ${currentScreen === 1 ? 'active' : ''}`}
        onClick={() => setCurrentScreen(1)}
      >
        <Search size={24} />
        <span>Search</span>
      </button>
      <button 
        className={`nav-item ${currentScreen === 2 ? 'active' : ''}`}
        onClick={() => setCurrentScreen(2)}
      >
        <Music2 size={24} />
        <span>Library</span>
      </button>
      <button 
        className={`nav-item ${currentScreen === 3 ? 'active' : ''}`}
        onClick={() => setCurrentScreen(3)}
      >
        <List size={24} />
        <span>Playlists</span>
      </button>
    </div>
  );

  const getScreenTitle = () => {
    const titles = ['Home', 'Search Music', 'Your Library', 'Playlists'];
    return titles[currentScreen] || 'SoundWave';
  };

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
    <div className="soundwave-phone-mockup">
      <div className={`phone-frame ${isDarkMode ? 'dark' : 'light'}`}>
        <div className="phone-screen">
          <StatusBar />
          <AppBar 
            title={getScreenTitle()}
            onThemeToggle={() => setIsDarkMode(!isDarkMode)}
          />
          
          <div className="main-content">
            {renderCurrentScreen()}
            <BottomMusicPlayer />
            <BottomNavigation />
          </div>
        </div>
      </div>
      
      <div className="demo-indicator">
        <div className="demo-dots">
          {[0, 1, 2, 3].map(index => (
            <div 
              key={index} 
              className={`demo-dot ${index === currentScreen ? 'active' : ''}`}
            />
          ))}
        </div>
        <span className="demo-text">Live App Preview</span>
      </div>
    </div>
  );
};

export default SoundWavePhoneMockup;
