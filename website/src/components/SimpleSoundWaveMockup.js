import React, { useState } from 'react';
import { 
  Home, 
  Search, 
  Music, 
  User,
  Play,
  Pause,
  SkipBack,
  SkipForward,
  Volume2,
  Heart,
  MoreVertical,
  Download,
  Share,
  Battery,
  Wifi,
  Signal
} from 'lucide-react';
import './SimpleSoundWaveMockup.css';

const SimpleSoundWaveMockup = () => {
  const [activeTab, setActiveTab] = useState('home');
  const [isPlaying, setIsPlaying] = useState(false);

  // Sample songs data
  const songs = [
    {
      id: 1,
      title: "Blinding Lights",
      artist: "The Weeknd",
      duration: "3:20",
      thumbnail: "https://via.placeholder.com/60x60/8E44AD/FFFFFF?text=BL"
    },
    {
      id: 2,
      title: "Watermelon Sugar",
      artist: "Harry Styles", 
      duration: "2:54",
      thumbnail: "https://via.placeholder.com/60x60/3498DB/FFFFFF?text=WS"
    },
    {
      id: 3,
      title: "Levitating",
      artist: "Dua Lipa",
      duration: "3:23", 
      thumbnail: "https://via.placeholder.com/60x60/E74C3C/FFFFFF?text=LV"
    }
  ];

  const renderHomeScreen = () => (
    <div className="screen-content">
      <div className="welcome-section">
        <h2>Good Morning</h2>
        <p>Ready to discover new music?</p>
      </div>
      
      <div className="recently-played">
        <h3>Recently Played</h3>
        <div className="songs-grid">
          {songs.map(song => (
            <div key={song.id} className="song-card">
              <img src={song.thumbnail} alt={song.title} className="song-image" />
              <div className="song-info">
                <h4>{song.title}</h4>
                <p>{song.artist}</p>
              </div>
              <button className="play-button" onClick={() => setIsPlaying(!isPlaying)}>
                {isPlaying ? <Pause size={16} /> : <Play size={16} />}
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderSearchScreen = () => (
    <div className="screen-content">
      <div className="search-bar">
        <Search size={20} />
        <input type="text" placeholder="Search songs, artists..." />
      </div>
      
      <div className="trending-section">
        <h3>Trending Now</h3>
        <div className="trending-list">
          <div className="trending-item">
            <img src="https://via.placeholder.com/50x50/27AE60/FFFFFF?text=T1" alt="Trending" />
            <div>
              <h4>As It Was</h4>
              <p>Harry Styles</p>
            </div>
            <Download size={16} />
          </div>
          <div className="trending-item">
            <img src="https://via.placeholder.com/50x50/F39C12/FFFFFF?text=T2" alt="Trending" />
            <div>
              <h4>Heat Waves</h4>
              <p>Glass Animals</p>
            </div>
            <Download size={16} />
          </div>
        </div>
      </div>
    </div>
  );

  const renderLibraryScreen = () => (
    <div className="screen-content">
      <div className="library-header">
        <h3>Your Library</h3>
        <MoreVertical size={20} />
      </div>
      
      <div className="library-stats">
        <div className="stat">
          <span className="stat-number">24</span>
          <span className="stat-label">Songs</span>
        </div>
        <div className="stat">
          <span className="stat-number">3</span>
          <span className="stat-label">Playlists</span>
        </div>
        <div className="stat">
          <span className="stat-number">12</span>
          <span className="stat-label">Artists</span>
        </div>
      </div>

      <div className="downloaded-songs">
        <h4>Downloaded Songs</h4>
        {songs.map(song => (
          <div key={song.id} className="library-song">
            <img src={song.thumbnail} alt={song.title} />
            <div className="song-details">
              <h5>{song.title}</h5>
              <p>{song.artist}</p>
            </div>
            <span className="duration">{song.duration}</span>
          </div>
        ))}
      </div>
    </div>
  );

  const renderProfileScreen = () => (
    <div className="screen-content">
      <div className="profile-header">
        <div className="profile-avatar">
          <User size={40} />
        </div>
        <h3>John Doe</h3>
        <p>Music Lover</p>
      </div>

      <div className="profile-stats">
        <div className="profile-stat">
          <span>Hours Listened</span>
          <strong>127</strong>
        </div>
        <div className="profile-stat">
          <span>Songs Downloaded</span>
          <strong>24</strong>
        </div>
      </div>

      <div className="profile-options">
        <div className="option">
          <span>Settings</span>
        </div>
        <div className="option">
          <span>About</span>
        </div>
        <div className="option">
          <span>Help</span>
        </div>
      </div>
    </div>
  );

  const renderCurrentScreen = () => {
    switch(activeTab) {
      case 'home': return renderHomeScreen();
      case 'search': return renderSearchScreen();
      case 'library': return renderLibraryScreen();
      case 'profile': return renderProfileScreen();
      default: return renderHomeScreen();
    }
  };

  return (
    <div className="simple-phone-mockup">
      <div className="phone-container">
        {/* Phone Frame */}
        <div className="phone-frame">
          
          {/* Status Bar */}
          <div className="status-bar">
            <span className="time">9:41</span>
            <div className="status-icons">
              <Signal size={14} />
              <Wifi size={14} />
              <Battery size={14} />
            </div>
          </div>

          {/* App Header */}
          <div className="app-header">
            <h1>SoundWave</h1>
          </div>

          {/* Main Content */}
          <div className="main-content">
            {renderCurrentScreen()}
          </div>

          {/* Now Playing (if song is playing) */}
          {isPlaying && (
            <div className="now-playing">
              <img src={songs[0].thumbnail} alt="Now Playing" />
              <div className="now-playing-info">
                <h5>{songs[0].title}</h5>
                <p>{songs[0].artist}</p>
              </div>
              <div className="now-playing-controls">
                <SkipBack size={16} />
                <button onClick={() => setIsPlaying(false)}>
                  <Pause size={20} />
                </button>
                <SkipForward size={16} />
              </div>
            </div>
          )}

          {/* Bottom Navigation */}
          <div className="bottom-nav">
            <button 
              className={activeTab === 'home' ? 'active' : ''}
              onClick={() => setActiveTab('home')}
            >
              <Home size={24} />
              <span>Home</span>
            </button>
            <button 
              className={activeTab === 'search' ? 'active' : ''}
              onClick={() => setActiveTab('search')}
            >
              <Search size={24} />
              <span>Search</span>
            </button>
            <button 
              className={activeTab === 'library' ? 'active' : ''}
              onClick={() => setActiveTab('library')}
            >
              <Music size={24} />
              <span>Library</span>
            </button>
            <button 
              className={activeTab === 'profile' ? 'active' : ''}
              onClick={() => setActiveTab('profile')}
            >
              <User size={24} />
              <span>Profile</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleSoundWaveMockup;
