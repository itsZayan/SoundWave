import React, { useState, useEffect } from 'react';
import { 
  Home, 
  Search, 
  Music, 
  Heart,
  Play, 
  Pause, 
  SkipBack, 
  SkipForward,
  Download,
  MoreVertical,
  Shuffle,
  Repeat,
  Volume2,
  ChevronLeft,
  Plus,
  Settings,
  User,
  Headphones,
  Mic,
  Radio,
  Clock,
  Signal,
  Wifi,
  Battery,
  CheckCircle
} from 'lucide-react';
import './PhoneMockup.css';

const PhoneMockup = () => {
  const [currentScreen, setCurrentScreen] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentSong, setCurrentSong] = useState(null);
  const [progress, setProgress] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [downloadProgress, setDownloadProgress] = useState({});
  const [isTransitioning, setIsTransitioning] = useState(false);
  const [showFullPlayer, setShowFullPlayer] = useState(false);

  // Sample data
  const featuredSongs = [
    {
      id: 1,
      title: "Blinding Lights",
      artist: "The Weeknd",
      duration: "3:20",
      thumbnail: "https://via.placeholder.com/60x60/ff6b6b/ffffff?text=BL",
      isDownloaded: true
    },
    {
      id: 2,
      title: "Watermelon Sugar",
      artist: "Harry Styles",
      duration: "2:54",
      thumbnail: "https://via.placeholder.com/60x60/4ecdc4/ffffff?text=WS",
      isDownloaded: false
    },
    {
      id: 3,
      title: "Levitating",
      artist: "Dua Lipa",
      duration: "3:23",
      thumbnail: "https://via.placeholder.com/60x60/45b7d1/ffffff?text=LE",
      isDownloaded: true
    }
  ];

  const trendingSongs = [
    {
      id: 4,
      title: "As It Was",
      artist: "Harry Styles",
      duration: "2:47",
      thumbnail: "https://via.placeholder.com/60x60/f7b731/ffffff?text=AW",
      views: "1.2B"
    },
    {
      id: 5,
      title: "Heat Waves",
      artist: "Glass Animals",
      duration: "3:58",
      thumbnail: "https://via.placeholder.com/60x60/5f27cd/ffffff?text=HW",
      views: "950M"
    },
    {
      id: 6,
      title: "Stay",
      artist: "The Kid LAROI",
      duration: "2:21",
      thumbnail: "https://via.placeholder.com/60x60/00d2d3/ffffff?text=ST",
      views: "800M"
    }
  ];

  const playlists = [
    {
      id: 1,
      name: "My Favorites",
      count: 25,
      thumbnail: "https://via.placeholder.com/80x80/ff6b6b/ffffff?text=❤️"
    },
    {
      id: 2,
      name: "Workout Hits",
      count: 18,
      thumbnail: "https://via.placeholder.com/80x80/4ecdc4/ffffff?text=💪"
    },
    {
      id: 3,
      name: "Chill Vibes",
      count: 32,
      thumbnail: "https://via.placeholder.com/80x80/45b7d1/ffffff?text=🌊"
    }
  ];

  // Auto-cycle screens
  useEffect(() => {
    const cycleScreens = () => {
      setIsTransitioning(true);
      
      setTimeout(() => {
        setCurrentScreen(prev => {
          const nextScreen = (prev + 1) % 4;
          
          // Simulate interactions based on screen
          setTimeout(() => {
            if (nextScreen === 1) {
              // Search screen - simulate typing
              const searchText = "Harry Styles";
              let currentText = "";
              const typingInterval = setInterval(() => {
                if (currentText.length < searchText.length) {
                  currentText += searchText[currentText.length];
                  setSearchQuery(currentText);
                } else {
                  clearInterval(typingInterval);
                }
              }, 150);
            } else if (nextScreen === 2) {
              // Library screen - start playing a song
              setTimeout(() => {
                setCurrentSong(featuredSongs[0]);
                setIsPlaying(true);
                setProgress(0);
              }, 1000);
            } else if (nextScreen === 0) {
              // Reset state when back to home
              setSearchQuery('');
              setIsPlaying(false);
              setCurrentSong(null);
              setProgress(0);
            }
          }, 800);
          
          return nextScreen;
        });
        
        setTimeout(() => {
          setIsTransitioning(false);
        }, 600);
      }, 300);
    };

    const interval = setInterval(cycleScreens, 5000);
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
          return prev + 0.8;
        });
      }, 100);
      return () => clearInterval(interval);
    }
  }, [isPlaying, currentSong]);

  const handlePlay = (song) => {
    if (currentSong?.id === song.id) {
      setIsPlaying(!isPlaying);
    } else {
      setCurrentSong(song);
      setIsPlaying(true);
      setProgress(0);
    }
  };

  const handleDownload = (song) => {
    setDownloadProgress(prev => ({ ...prev, [song.id]: 0 }));
    
    const interval = setInterval(() => {
      setDownloadProgress(prev => {
        const newProgress = (prev[song.id] || 0) + Math.random() * 20;
        if (newProgress >= 100) {
          clearInterval(interval);
          return { ...prev, [song.id]: 100 };
        }
        return { ...prev, [song.id]: newProgress };
      });
    }, 200);
  };

  // Screen Components
  const StatusBar = () => (
    <div className="status-bar">
      <div className="status-left">
        <span>9:41</span>
      </div>
      <div className="status-right">
        <Signal size={14} />
        <Wifi size={14} />
        <Battery size={14} />
        <span>100%</span>
      </div>
    </div>
  );

  const HomeScreen = () => (
    <div className="screen home-screen">
      <div className="screen-header">
        <div className="header-left">
          <div className="app-icon">
            <Music size={24} />
          </div>
          <h1>SoundWave</h1>
        </div>
        <div className="header-right">
          <button className="icon-btn">
            <Settings size={20} />
          </button>
          <button className="icon-btn">
            <User size={20} />
          </button>
        </div>
      </div>
      
      <div className="screen-content">
        <div className="welcome-section">
          <h2>Good evening, Mahad</h2>
          <p>What would you like to listen to?</p>
        </div>
        
        <div className="quick-actions">
          <div className="quick-action">
            <div className="quick-icon liked-songs">
              <Heart size={20} />
            </div>
            <span>Liked Songs</span>
          </div>
          <div className="quick-action">
            <div className="quick-icon downloads">
              <Download size={20} />
            </div>
            <span>Downloads</span>
          </div>
          <div className="quick-action">
            <div className="quick-icon radio">
              <Radio size={20} />
            </div>
            <span>Radio</span>
          </div>
          <div className="quick-action">
            <div className="quick-icon podcasts">
              <Mic size={20} />
            </div>
            <span>Podcasts</span>
          </div>
        </div>
        
        <div className="section">
          <h3>Recently Played</h3>
          <div className="songs-grid">
            {featuredSongs.slice(0, 3).map(song => (
              <div key={song.id} className="song-card">
                <div className="song-thumbnail">
                  <img src={song.thumbnail} alt={song.title} />
                  <button 
                    className="play-overlay"
                    onClick={() => handlePlay(song)}
                  >
                    {currentSong?.id === song.id && isPlaying ? 
                      <Pause size={24} /> : <Play size={24} />
                    }
                  </button>
                </div>
                <div className="song-info">
                  <h4>{song.title}</h4>
                  <p>{song.artist}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );

  const SearchScreen = () => (
    <div className="screen search-screen">
      <div className="screen-header">
        <h1>Search</h1>
      </div>
      
      <div className="screen-content">
        <div className="search-container">
          <div className="search-input-wrapper">
            <Search size={20} />
            <input
              type="text"
              placeholder="Artists, songs, or podcasts"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
        
        <div className="section">
          <h3>Trending Now</h3>
          <div className="trending-list">
            {trendingSongs.map(song => (
              <div key={song.id} className="trending-item">
                <div className="trending-thumbnail">
                  <img src={song.thumbnail} alt={song.title} />
                </div>
                <div className="trending-info">
                  <h4>{song.title}</h4>
                  <p>{song.artist}</p>
                  <span className="views">{song.views} views</span>
                </div>
                <div className="trending-actions">
                  <button 
                    className="icon-btn"
                    onClick={() => handlePlay(song)}
                  >
                    <Play size={18} />
                  </button>
                  <button 
                    className="icon-btn"
                    onClick={() => handleDownload(song)}
                  >
                    {downloadProgress[song.id] >= 100 ? 
                      <CheckCircle size={18} className="success" /> :
                      <Download size={18} />
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

  const LibraryScreen = () => (
    <div className="screen library-screen">
      <div className="screen-header">
        <h1>Your Library</h1>
        <button className="icon-btn">
          <Plus size={20} />
        </button>
      </div>
      
      <div className="screen-content">
        <div className="library-tabs">
          <button className="lib-tab active">All</button>
          <button className="lib-tab">Playlists</button>
          <button className="lib-tab">Artists</button>
          <button className="lib-tab">Albums</button>
        </div>
        
        <div className="section">
          <div className="downloaded-songs">
            <h3>Downloaded Music</h3>
            <div className="songs-list">
              {featuredSongs.filter(song => song.isDownloaded).map(song => (
                <div key={song.id} className="song-item">
                  <div className="song-thumbnail">
                    <img src={song.thumbnail} alt={song.title} />
                  </div>
                  <div className="song-details">
                    <h4>{song.title}</h4>
                    <p>{song.artist}</p>
                    <div className="song-meta">
                      <Download size={12} />
                      <span>Downloaded</span>
                    </div>
                  </div>
                  <button 
                    className="icon-btn"
                    onClick={() => handlePlay(song)}
                  >
                    {currentSong?.id === song.id && isPlaying ? 
                      <Pause size={20} /> : <Play size={20} />
                    }
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  const PlaylistsScreen = () => (
    <div className="screen playlists-screen">
      <div className="screen-header">
        <h1>Playlists</h1>
        <button className="icon-btn">
          <Plus size={20} />
        </button>
      </div>
      
      <div className="screen-content">
        <div className="create-playlist-card">
          <div className="create-icon">
            <Plus size={24} />
          </div>
          <div>
            <h4>Create playlist</h4>
            <p>Make your own mix</p>
          </div>
        </div>
        
        <div className="playlists-grid">
          {playlists.map(playlist => (
            <div key={playlist.id} className="playlist-card">
              <div className="playlist-thumbnail">
                <img src={playlist.thumbnail} alt={playlist.name} />
              </div>
              <div className="playlist-info">
                <h4>{playlist.name}</h4>
                <p>{playlist.count} songs</p>
              </div>
              <button className="icon-btn">
                <MoreVertical size={16} />
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const MiniPlayer = () => {
    if (!currentSong || showFullPlayer) return null;
    
    return (
      <div className="mini-player" onClick={() => setShowFullPlayer(true)}>
        <div className="mini-progress" style={{ width: `${progress}%` }} />
        <div className="mini-content">
          <div className="mini-thumbnail">
            <img src={currentSong.thumbnail} alt={currentSong.title} />
          </div>
          <div className="mini-info">
            <h5>{currentSong.title}</h5>
            <p>{currentSong.artist}</p>
          </div>
          <div className="mini-controls">
            <button 
              className="icon-btn"
              onClick={(e) => {
                e.stopPropagation();
                setIsPlaying(!isPlaying);
              }}
            >
              {isPlaying ? <Pause size={20} /> : <Play size={20} />}
            </button>
          </div>
        </div>
      </div>
    );
  };

  const BottomNav = () => (
    <div className="bottom-nav">
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
        <Music size={24} />
        <span>Library</span>
      </button>
      <button 
        className={`nav-item ${currentScreen === 3 ? 'active' : ''}`}
        onClick={() => setCurrentScreen(3)}
      >
        <Heart size={24} />
        <span>Playlists</span>
      </button>
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
    <div className="phone-mockup">
      <div className="phone-frame">
        <div className="phone-screen">
          <StatusBar />
          <div className={`screen-container ${isTransitioning ? 'transitioning' : ''}`}>
            {renderCurrentScreen()}
            <MiniPlayer />
            <BottomNav />
          </div>
        </div>
      </div>
      
      <div className="demo-indicator">
        <div className="demo-dot active"></div>
        <div className="demo-dot"></div>
        <div className="demo-dot"></div>
        <div className="demo-dot"></div>
        <span className="demo-text">Live Demo</span>
      </div>
    </div>
  );
};

export default PhoneMockup;
