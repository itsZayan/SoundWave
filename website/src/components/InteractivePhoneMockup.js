import React, { useState, useEffect } from 'react';
import { 
  Search, 
  Home, 
  Music2, 
  PlayCircle, 
  Download, 
  Play, 
  Pause, 
  SkipBack, 
  SkipForward,
  Plus,
  Heart,
  MoreVertical,
  ArrowLeft,
  Shuffle,
  Repeat,
  Volume2,
  ChevronDown,
  CheckCircle,
  Clock,
  Wifi,
  Signal,
  Battery,
  Settings,
  Trash2,
  Edit,
  X,
  Star,
  Headphones
} from 'lucide-react';
import './InteractivePhoneMockup.css';

const InteractivePhoneMockup = () => {
  const [currentTab, setCurrentTab] = useState(0); // 0: Home, 1: Search, 2: Library, 3: Playlists
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentSong, setCurrentSong] = useState(null);
  const [progress, setProgress] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [downloadProgress, setDownloadProgress] = useState({});
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [transitionType, setTransitionType] = useState('');
  const [isAutoMode, setIsAutoMode] = useState(true);
  const [showPlayer, setShowPlayer] = useState(false);

  // Sample data that mimics your Flutter app
  const recentSongs = [
    {
      id: 1,
      title: "Bohemian Rhapsody",
      artist: "Queen",
      thumbnail: "/api/placeholder/60/60",
      duration: "5:55",
      isLocal: true
    },
    {
      id: 2,
      title: "Imagine",
      artist: "John Lennon",
      thumbnail: "/api/placeholder/60/60",
      duration: "3:03",
      isLocal: true
    },
    {
      id: 3,
      title: "Hotel California",
      artist: "Eagles",
      thumbnail: "/api/placeholder/60/60",
      duration: "6:30",
      isLocal: true
    }
  ];

  const trendingVideos = [
    {
      id: 4,
      title: "Shape of You",
      artist: "Ed Sheeran",
      thumbnail: "/api/placeholder/60/60",
      duration: "3:53",
      views: "6.2B"
    },
    {
      id: 5,
      title: "Blinding Lights",
      artist: "The Weeknd", 
      thumbnail: "/api/placeholder/60/60",
      duration: "3:20",
      views: "3.8B"
    },
    {
      id: 6,
      title: "Bad Habits",
      artist: "Ed Sheeran",
      thumbnail: "/api/placeholder/60/60",
      duration: "3:51",
      views: "1.2B"
    }
  ];

  const playlists = [
    {
      id: 1,
      name: "My Favorites",
      songs: recentSongs,
      songCount: 3
    },
    {
      id: 2,
      name: "Workout Mix",
      songs: [],
      songCount: 0
    }
  ];

  // Tab navigation data matching your Flutter app
  const tabs = [
    { icon: Home, label: 'Home' },
    { icon: Search, label: 'Search' },
    { icon: Music2, label: 'Library' },
    { icon: PlayCircle, label: 'Playlists' }
  ];

  // Simulate play/pause functionality
  const handlePlayPause = (song) => {
    if (currentSong?.id === song.id) {
      setIsPlaying(!isPlaying);
    } else {
      setCurrentSong(song);
      setIsPlaying(true);
      setProgress(0);
    }
  };

  // Simulate download functionality
  const handleDownload = (song) => {
    setDownloadProgress({...downloadProgress, [song.id]: 0});
    
    const progressInterval = setInterval(() => {
      setDownloadProgress(prev => {
        const newProgress = (prev[song.id] || 0) + Math.random() * 15;
        if (newProgress >= 100) {
          clearInterval(progressInterval);
          return {...prev, [song.id]: 100};
        }
        return {...prev, [song.id]: newProgress};
      });
    }, 200);
  };

  // Simulate search functionality
  const handleSearch = (query) => {
    setSearchQuery(query);
    if (query.trim()) {
      // Simulate search results
      setSearchResults(trendingVideos.filter(video => 
        video.title.toLowerCase().includes(query.toLowerCase()) ||
        video.artist.toLowerCase().includes(query.toLowerCase())
      ));
    } else {
      setSearchResults([]);
    }
  };

  // Enhanced auto-cycling with cinematic transitions
  useEffect(() => {
    const cycleScreens = () => {
      setIsTransitioning(true);
      
      // Set transition type based on direction
      const transitionTypes = ['slideLeft', 'fadeZoom', 'flipHorizontal', 'cubeRotate'];
      const randomTransition = transitionTypes[Math.floor(Math.random() * transitionTypes.length)];
      setTransitionType(randomTransition);
      
      setTimeout(() => {
        setCurrentTab(prev => {
          const nextTab = (prev + 1) % 4;
          
          // Auto-simulate realistic app behaviors
          setTimeout(() => {
            if (nextTab === 1) {
              // Search screen: progressive typing animation
              const searchText = 'Shape of You';
              let currentText = '';
              const typingInterval = setInterval(() => {
                if (currentText.length < searchText.length) {
                  currentText += searchText[currentText.length];
                  setSearchQuery(currentText);
                } else {
                  clearInterval(typingInterval);
                  setTimeout(() => {
                    handleSearch(searchText);
                    // Simulate download after search
                    setTimeout(() => {
                      if (trendingVideos.length > 0) {
                        handleDownload(trendingVideos[0]);
                      }
                    }, 1500);
                  }, 500);
                }
              }, 100);
            } else if (nextTab === 2) {
              // Library screen: auto-play and show mini player
              setTimeout(() => {
                if (recentSongs.length > 0) {
                  setCurrentSong(recentSongs[0]);
                  setIsPlaying(true);
                  setProgress(0);
                }
              }, 800);
            } else if (nextTab === 3) {
              // Playlists screen: highlight playlist interaction
              setTimeout(() => {
                // Simulate playlist creation visual feedback
                const playlistItems = document.querySelectorAll('.playlist-item');
                playlistItems.forEach((item, index) => {
                  setTimeout(() => {
                    item.style.transform = 'scale(1.02)';
                    setTimeout(() => {
                      item.style.transform = 'scale(1)';
                    }, 300);
                  }, index * 200);
                });
              }, 1000);
            } else if (nextTab === 0) {
              // Reset to clean state
              setSearchQuery('');
              setSearchResults([]);
              setIsPlaying(false);
              setCurrentSong(null);
              setProgress(0);
            }
          }, 600);
          
          return nextTab;
        });
        
        setTimeout(() => {
          setIsTransitioning(false);
        }, 800);
      }, 400);
    };

    // Start with initial delay
    const initialTimeout = setTimeout(() => {
      cycleScreens();
      const interval = setInterval(cycleScreens, 5000); // 5 seconds per screen for better viewing
      return () => clearInterval(interval);
    }, 2000);

    return () => clearTimeout(initialTimeout);
  }, []);

  // Progress simulation for currently playing song
  useEffect(() => {
    if (isPlaying && currentSong) {
      const interval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 100) {
            setIsPlaying(false);
            return 0;
          }
          return prev + 0.5;
        });
      }, 100);
      
      return () => clearInterval(interval);
    }
  }, [isPlaying, currentSong]);

  // Handle click events - disable auto mode when user interacts
  const handleUserInteraction = () => {
    setIsAutoMode(false);
  };

  // Modified tab change handler
  const handleTabChange = (index) => {
    setIsAutoMode(false); // Disable auto mode on user interaction
    setCurrentTab(index);
  };

  // Render status bar (matching your Flutter app)
  const renderStatusBar = () => (
    <div className="mock-status-bar">
      <div className="status-left">9:41</div>
      <div className="status-right">
        <Signal size={12} className="status-icon" />
        <Wifi size={12} className="status-icon" />
        <Battery size={12} className="status-icon" />
        <span className="battery-percent">100%</span>
      </div>
    </div>
  );

  // Render app header (matching your Flutter app)
  const renderAppHeader = () => (
    <div className="mock-app-header">
      <div className="app-title-section">
        <img src="/app-icon.jpg" alt="SoundWave" className="mock-app-icon" />
        <h1 className="mock-app-title">SoundWave</h1>
      </div>
      <Settings size={20} className="header-icon" />
    </div>
  );

  // Home Screen (matching your Flutter app's HomeScreen)
  const renderHomeScreen = () => (
    <div className="mock-screen-content">
      {renderAppHeader()}
      <div className="mock-screen-body">
        <div className="welcome-section">
          <h2 className="welcome-text">Good evening</h2>
          <p className="welcome-subtitle">What would you like to listen to?</p>
        </div>
        
        <div className="quick-actions">
          <div className="quick-action-item">
            <div className="quick-icon">
              <Headphones size={20} />
            </div>
            <span>Liked Songs</span>
          </div>
          <div className="quick-action-item">
            <div className="quick-icon">
              <Download size={20} />
            </div>
            <span>Downloads</span>
          </div>
        </div>

        <div className="section">
          <h3 className="section-title">Recently Added</h3>
          <div className="songs-list">
            {recentSongs.slice(0, 3).map((song) => (
              <div key={song.id} className="mock-song-item">
                <div className="song-thumbnail">
                  <Music2 size={24} />
                </div>
                <div className="song-info">
                  <div className="song-title">{song.title}</div>
                  <div className="song-artist">{song.artist}</div>
                </div>
                <div className="song-actions">
                  <button 
                    className="play-btn"
                    onClick={() => handlePlayPause(song)}
                  >
                    {currentSong?.id === song.id && isPlaying ? 
                      <Pause size={16} /> : <Play size={16} />
                    }
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  // Search Screen (matching your Flutter app's SearchScreen)
  const renderSearchScreen = () => (
    <div className="mock-screen-content">
      <div className="search-header">
        <h1 className="screen-title">Search Music</h1>
      </div>
      <div className="mock-screen-body">
        <div className="search-container">
          <div className="search-input-container">
            <Search size={20} className="search-icon" />
            <input
              type="text"
              placeholder="Search for music on YouTube..."
              value={searchQuery}
              onChange={(e) => handleSearch(e.target.value)}
              className="search-input"
            />
          </div>
        </div>

        <div className="search-content">
          {searchQuery === '' ? (
            <div className="trending-section">
              <h3 className="section-title">Trending Music</h3>
              <div className="songs-list">
                {trendingVideos.map((video) => (
                  <div key={video.id} className="mock-song-item">
                    <div className="song-thumbnail">
                      <Music2 size={24} />
                    </div>
                    <div className="song-info">
                      <div className="song-title">{video.title}</div>
                      <div className="song-artist">{video.artist}</div>
                      <div className="song-meta">{video.views} views</div>
                    </div>
                    <div className="song-actions">
                      <button 
                        className="play-btn"
                        onClick={() => handlePlayPause(video)}
                      >
                        <Play size={16} />
                      </button>
                      <button 
                        className="download-btn"
                        onClick={() => handleDownload(video)}
                      >
                        {downloadProgress[video.id] !== undefined ? (
                          downloadProgress[video.id] === 100 ? 
                            <CheckCircle size={16} className="success" /> :
                            <div className="download-progress">
                              {Math.round(downloadProgress[video.id])}%
                            </div>
                        ) : (
                          <Download size={16} />
                        )}
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <div className="search-results">
              {searchResults.length > 0 ? (
                <div className="songs-list">
                  {searchResults.map((result) => (
                    <div key={result.id} className="mock-song-item">
                      <div className="song-thumbnail">
                        <Music2 size={24} />
                      </div>
                      <div className="song-info">
                        <div className="song-title">{result.title}</div>
                        <div className="song-artist">{result.artist}</div>
                      </div>
                      <div className="song-actions">
                        <button 
                          className="play-btn"
                          onClick={() => handlePlayPause(result)}
                        >
                          <Play size={16} />
                        </button>
                        <button 
                          className="download-btn"
                          onClick={() => handleDownload(result)}
                        >
                          <Download size={16} />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="no-results">
                  <Search size={48} className="no-results-icon" />
                  <p>No results found</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );

  // Library Screen (matching your Flutter app's LibraryScreen)
  const renderLibraryScreen = () => (
    <div className="mock-screen-content">
      <div className="library-header">
        <h1 className="screen-title">Your Library</h1>
        <button className="refresh-btn">
          <Download size={20} />
        </button>
      </div>
      <div className="mock-screen-body">
        {recentSongs.length > 0 ? (
          <div className="songs-list">
            {recentSongs.map((song) => (
              <div key={song.id} className="mock-song-item downloaded">
                <div className="song-thumbnail">
                  <Music2 size={24} />
                </div>
                <div className="song-info">
                  <div className="song-title">{song.title}</div>
                  <div className="song-artist">{song.artist}</div>
                  <div className="song-meta">
                    <Music2 size={12} className="file-type-icon" />
                    <span>Audio</span>
                  </div>
                </div>
                <div className="song-actions">
                  <button 
                    className="play-btn"
                    onClick={() => {
                      handlePlayPause(song);
                      setShowPlayer(true);
                    }}
                  >
                    <Play size={16} />
                  </button>
                  <button className="delete-btn">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="empty-library">
            <Music2 size={64} className="empty-icon" />
            <h3>No downloaded music</h3>
            <p>Download music from the search tab to listen offline</p>
          </div>
        )}
      </div>
    </div>
  );

  // Playlists Screen (matching your Flutter app's PlaylistsScreen)
  const renderPlaylistsScreen = () => (
    <div className="mock-screen-content">
      <div className="playlists-header">
        <h1 className="screen-title">Playlists</h1>
        <button className="add-playlist-btn">
          <Plus size={20} />
        </button>
      </div>
      <div className="mock-screen-body">
        {playlists.length > 0 ? (
          <div className="playlists-list">
            {playlists.map((playlist) => (
              <div key={playlist.id} className="playlist-item">
                <div className="playlist-thumbnail">
                  <PlayCircle size={30} />
                </div>
                <div className="playlist-info">
                  <div className="playlist-name">{playlist.name}</div>
                  <div className="playlist-meta">{playlist.songCount} songs</div>
                </div>
                <div className="playlist-actions">
                  <button className="more-btn">
                    <MoreVertical size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="empty-playlists">
            <PlayCircle size={64} className="empty-icon" />
            <h3>No playlists yet</h3>
            <p>Tap the + button to create your first playlist</p>
          </div>
        )}
      </div>
    </div>
  );

  // Player Screen (matching your Flutter app's PlayerScreen)
  const renderPlayerScreen = () => {
    if (!currentSong) return null;

    return (
      <div className="mock-player-screen">
        <div className="player-header">
          <button 
            className="back-btn"
            onClick={() => setShowPlayer(false)}
          >
            <ChevronDown size={24} />
          </button>
          <span className="player-title">Now Playing</span>
          <button className="more-btn">
            <MoreVertical size={24} />
          </button>
        </div>
        
        <div className="player-content">
          <div className="album-art">
            <div className="album-art-placeholder">
              <Music2 size={80} />
            </div>
          </div>
          
          <div className="song-details">
            <h2 className="player-song-title">{currentSong.title}</h2>
            <p className="player-song-artist">{currentSong.artist}</p>
          </div>
          
          <div className="player-progress">
            <div className="progress-bar">
              <div 
                className="progress-fill" 
                style={{ width: `${progress}%` }}
              ></div>
            </div>
            <div className="progress-time">
              <span>1:23</span>
              <span>{currentSong.duration}</span>
            </div>
          </div>
          
          <div className="player-controls">
            <button className="control-btn secondary">
              <SkipBack size={24} />
            </button>
            <button 
              className="control-btn primary"
              onClick={() => setIsPlaying(!isPlaying)}
            >
              {isPlaying ? <Pause size={32} /> : <Play size={32} />}
            </button>
            <button className="control-btn secondary">
              <SkipForward size={24} />
            </button>
          </div>
        </div>
      </div>
    );
  };

  // Bottom Music Player (matching your Flutter app's mini player)
  const renderBottomPlayer = () => {
    if (!currentSong || showPlayer) return null;

    return (
      <div 
        className="bottom-player"
        onClick={() => setShowPlayer(true)}
      >
        <div className="mini-player-content">
          <div className="mini-thumbnail">
            <Music2 size={20} />
          </div>
          <div className="mini-info">
            <div className="mini-title">{currentSong.title}</div>
            <div className="mini-artist">{currentSong.artist}</div>
          </div>
          <button 
            className="mini-play-btn"
            onClick={(e) => {
              e.stopPropagation();
              setIsPlaying(!isPlaying);
            }}
          >
            {isPlaying ? <Pause size={20} /> : <Play size={20} />}
          </button>
        </div>
        <div 
          className="mini-progress" 
          style={{ width: `${progress}%` }}
        ></div>
      </div>
    );
  };

  // Bottom Navigation (matching your Flutter app's bottom navigation)
  const renderBottomNavigation = () => (
    <div className="mock-bottom-nav">
      {tabs.map((tab, index) => {
        const IconComponent = tab.icon;
        return (
          <button
            key={index}
            className={`nav-tab ${currentTab === index ? 'active' : ''}`}
            onClick={() => setCurrentTab(index)}
          >
            <IconComponent size={24} />
            <span className="nav-label">{tab.label}</span>
          </button>
        );
      })}
    </div>
  );

  // Main screen content based on current tab
  const renderMainContent = () => {
    switch (currentTab) {
      case 0: return renderHomeScreen();
      case 1: return renderSearchScreen();
      case 2: return renderLibraryScreen();
      case 3: return renderPlaylistsScreen();
      default: return renderHomeScreen();
    }
  };

  return (
    <div className="interactive-phone-mockup showcase-mode">
      <div className="phone-frame">
        <div className="phone-screen">
          {renderStatusBar()}
          
          <div className={`screen-container ${isTransitioning ? `transition-${transitionType}` : ''}`}>
            {renderMainContent()}
            {renderBottomPlayer()}
            {renderBottomNavigation()}
          </div>
        </div>
      </div>
      <div className="demo-indicator">
        <div className="demo-text">Live App Preview</div>
        <div className="demo-progress-bar">
          <div className="demo-progress-fill"></div>
        </div>
      </div>
    </div>
  );
};

export default InteractivePhoneMockup;
