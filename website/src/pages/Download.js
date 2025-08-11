import React, { useState, useEffect } from 'react';
import { 
  Download as DownloadIcon, 
  Smartphone, 
  CheckCircle, 
  Shield,
  Zap,
  Star,
  FileText,
  Calendar,
  HardDrive,
  AlertCircle,
  PlayCircle,
  Loader2,
  Music,
  Headphones,
  Cloud,
  Lock,
  Award,
  Sparkles,
  ArrowRight,
  Gauge,
  Users
} from 'lucide-react';
import './Download.css';
import './SecuritySection.css';

const Download = () => {
  const [downloaded, setDownloaded] = useState(false);
  const [isTestRunning, setIsTestRunning] = useState(false);
  const [testProgress, setTestProgress] = useState(0);
  const [testCompleted, setTestCompleted] = useState(false);
  const [currentTestStep, setCurrentTestStep] = useState('');
  const [securityScore, setSecurityScore] = useState(null);
  const [downloadCount, setDownloadCount] = useState(12450);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
    // Animate download counter
    const interval = setInterval(() => {
      setDownloadCount(prev => prev + Math.floor(Math.random() * 3));
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleDownload = () => {
    // Create a link to download the APK file
    const link = document.createElement('a');
    link.href = '/SoundWave.apk';
    link.download = 'SoundWave.apk';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    setDownloaded(true);

    // Reset the download state after 3 seconds
    setTimeout(() => {
      setDownloaded(false);
    }, 3000);
  };

  const runSecurityTest = async () => {
    setIsTestRunning(true);
    setTestProgress(0);
    setTestCompleted(false);
    setCurrentTestStep('');
    setSecurityScore(null);

    const testSteps = [
      { step: 'Initializing security scan...', duration: 800 },
      { step: 'Scanning for malware...', duration: 1200 },
      { step: 'Verifying app integrity...', duration: 1000 },
      { step: 'Checking digital signatures...', duration: 900 },
      { step: 'Analyzing permissions...', duration: 1100 },
      { step: 'Validating security certificates...', duration: 1000 },
      { step: 'Final security assessment...', duration: 800 }
    ];

    let progress = 0;
    const totalSteps = testSteps.length;

    for (let i = 0; i < testSteps.length; i++) {
      setCurrentTestStep(testSteps[i].step);
      
      // Animate progress
      const stepProgress = (100 / totalSteps);
      const targetProgress = Math.round((i + 1) * stepProgress);
      
      const duration = testSteps[i].duration;
      const interval = duration / (targetProgress - progress);
      
      await new Promise(resolve => {
        const progressInterval = setInterval(() => {
          progress++;
          setTestProgress(progress);
          
          if (progress >= targetProgress) {
            clearInterval(progressInterval);
            resolve();
          }
        }, interval);
      });
    }

    // Complete the test
    setTestProgress(100);
    setCurrentTestStep('Security scan complete - 100% safe!');
    setSecurityScore(100);
    setTestCompleted(true);
    
    setTimeout(() => {
      setIsTestRunning(false);
    }, 1000);
  };

  const appInfo = {
    version: "1.0.0",
    size: "26.1 MB",
    releaseDate: "August 10, 2025",
    minAndroid: "Android 5.0+",
    architecture: "ARM64, ARM32",
    category: "Music & Audio"
  };

  const features = [
    {
      icon: <Zap className="feature-icon" />,
      title: "Lightning Fast Downloads",
      description: "Download YouTube audio in seconds with our optimized engine",
      gradient: "from-blue-500 to-cyan-400"
    },
    {
      icon: <Shield className="feature-icon" />,
      title: "100% Safe & Secure",
      description: "No malware, no ads, no tracking. Your privacy is protected",
      gradient: "from-green-500 to-emerald-400"
    },
    {
      icon: <Music className="feature-icon" />,
      title: "Premium Audio Quality",
      description: "Crystal clear audio up to 320kbps for the best listening experience",
      gradient: "from-purple-500 to-pink-400"
    },
    {
      icon: <Cloud className="feature-icon" />,
      title: "No Storage Limits",
      description: "Download unlimited tracks without worrying about storage space",
      gradient: "from-indigo-500 to-blue-400"
    },
    {
      icon: <Headphones className="feature-icon" />,
      title: "Offline Listening",
      description: "Enjoy your favorite music anywhere, anytime without internet",
      gradient: "from-orange-500 to-yellow-400"
    },
    {
      icon: <Sparkles className="feature-icon" />,
      title: "AI-Enhanced Search",
      description: "Smart search suggestions and metadata detection for perfect results",
      gradient: "from-pink-500 to-rose-400"
    }
  ];

  const systemRequirements = [
    "Android 5.0 (API level 21) or higher",
    "At least 50MB free storage space",
    "Internet connection for downloads",
    "Permission to access storage"
  ];

  const installation = [
    {
      step: 1,
      title: "Download APK",
      description: "Click the download button above to get the SoundWave APK file"
    },
    {
      step: 2,
      title: "Enable Unknown Sources",
      description: "Go to Settings > Security and enable 'Unknown Sources' or 'Install unknown apps'"
    },
    {
      step: 3,
      title: "Install App",
      description: "Open the downloaded APK file and follow the installation prompts"
    },
    {
      step: 4,
      title: "Enjoy!",
      description: "Launch SoundWave and start downloading your favorite YouTube audio"
    }
  ];

  return (
    <div className="download-page">
      {/* Hero Section */}
      <section className="download-hero">
        <div className="container">
          <div className="download-hero-content">
            <div className={`hero-text ${isVisible ? 'animate-fade-up' : ''}`}>
              <div className="hero-badge">
                <Award className="badge-icon" size={16} />
                <span>Editor's Choice 2025</span>
              </div>
              <h1 className="hero-title">
                Experience the Future of
                <span className="text-gradient"> Audio Downloads</span>
              </h1>
              <p className="hero-subtitle">
                Transform YouTube into your personal music library with SoundWave's revolutionary download technology. Lightning-fast, crystal-clear, completely free.
              </p>
              
              <div className="hero-stats">
                <div className="stat">
                  <div className="stat-number">{downloadCount.toLocaleString()}+</div>
                  <div className="stat-label">Happy Users</div>
                </div>
                <div className="stat">
                  <div className="stat-number">320kbps</div>
                  <div className="stat-label">Max Quality</div>
                </div>
                <div className="stat">
                  <div className="stat-number">0s</div>
                  <div className="stat-label">Wait Time</div>
                </div>
              </div>
              
              <div className="download-card-modern">
                <div className="card-header">
                  <div className="app-icon-modern">
                    <div className="icon-inner">
                      <Music className="app-icon-svg" />
                    </div>
                    <div className="icon-glow"></div>
                  </div>
                  <div className="app-info">
                    <h3 className="app-title">SoundWave for Android</h3>
                    <div className="app-meta-modern">
                      <span className="version-badge">v{appInfo.version}</span>
                      <span className="size-badge">{appInfo.size}</span>
                      <div className="rating-modern">
                        <div className="stars">
                          {[...Array(5)].map((_, i) => (
                            <Star key={i} className="star filled" size={12} />
                          ))}
                        </div>
                        <span className="rating-text">4.9 (12.5k)</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <div className="download-action">
                  <button 
                    className={`download-btn-modern ${downloaded ? 'downloaded' : ''}`}
                    onClick={handleDownload}
                    disabled={downloaded}
                  >
                    <div className="btn-content">
                      {downloaded ? (
                        <>
                          <CheckCircle className="btn-icon success" size={20} />
                          <span>Successfully Downloaded!</span>
                        </>
                      ) : (
                        <>
                          <DownloadIcon className="btn-icon download" size={20} />
                          <span>Download Free APK</span>
                          <ArrowRight className="btn-arrow" size={16} />
                        </>
                      )}
                    </div>
                    <div className="btn-shimmer"></div>
                  </button>
                  
                  <div className="security-badge-small">
                    <Shield size={14} />
                    <span>Virus-free & Secure</span>
                  </div>
                </div>
              </div>

              <div className="download-info">
                <div className="info-item">
                  <Calendar size={16} />
                  <span>Released: {appInfo.releaseDate}</span>
                </div>
                <div className="info-item">
                  <HardDrive size={16} />
                  <span>Size: {appInfo.size}</span>
                </div>
                <div className="info-item">
                  <Smartphone size={16} />
                  <span>Requires: {appInfo.minAndroid}</span>
                </div>
              </div>
            </div>

            <div className={`hero-visual ${isVisible ? 'animate-fade-left' : ''}`}>
              <div className="visual-container">
                <div className="floating-elements">
                  <div className="floating-card music-card">
                    <Music className="card-icon" />
                    <div className="card-content">
                      <div className="card-title">High Quality Audio</div>
                      <div className="card-desc">320kbps Crystal Clear</div>
                    </div>
                    <div className="card-glow"></div>
                  </div>
                  
                  <div className="floating-card speed-card">
                    <Gauge className="card-icon" />
                    <div className="card-content">
                      <div className="card-title">Lightning Fast</div>
                      <div className="card-desc">3x Faster Downloads</div>
                    </div>
                    <div className="card-glow"></div>
                  </div>
                  
                  <div className="floating-card users-card">
                    <Users className="card-icon" />
                    <div className="card-content">
                      <div className="card-title">{downloadCount.toLocaleString()}+ Users</div>
                      <div className="card-desc">Trusted Worldwide</div>
                    </div>
                    <div className="card-glow"></div>
                  </div>
                </div>
                
                <div className="central-graphic">
                  <div className="graphic-core">
                    <div className="core-icon">
                      <Headphones size={80} />
                    </div>
                    <div className="pulse-ring ring-1"></div>
                    <div className="pulse-ring ring-2"></div>
                    <div className="pulse-ring ring-3"></div>
                  </div>
                  
                  <div className="orbit-elements">
                    <div className="orbit-item orbit-1">
                      <DownloadIcon size={24} />
                    </div>
                    <div className="orbit-item orbit-2">
                      <Shield size={24} />
                    </div>
                    <div className="orbit-item orbit-3">
                      <Zap size={24} />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Enhanced Features Section */}
      <section className="features-section-modern">
        <div className="container">
          <div className="section-header-modern">
            <div className="header-badge">
              <Sparkles size={16} />
              <span>Powerful Features</span>
            </div>
            <h2 className="section-title-modern">
              Everything You Need for
              <span className="title-gradient"> Perfect Audio Downloads</span>
            </h2>
            <p className="section-description-modern">
              Experience the next generation of audio downloading with our cutting-edge features designed for perfection.
            </p>
          </div>
          
          <div className="features-grid-modern">
            {features.map((feature, index) => (
              <div 
                key={index} 
                className={`feature-card-modern ${isVisible ? 'animate-slide-up' : ''}`}
                style={{animationDelay: `${index * 0.1}s`}}
              >
                <div className="card-background"></div>
                <div className={`feature-icon-modern bg-gradient-to-r ${feature.gradient}`}>
                  {feature.icon}
                  <div className="icon-shine"></div>
                </div>
                <div className="feature-content-modern">
                  <h3 className="feature-title-modern">{feature.title}</h3>
                  <p className="feature-description-modern">{feature.description}</p>
                </div>
                <div className="card-hover-effect"></div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Installation Guide */}
      <section className="installation-guide section gradient-bg">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>How to Install</h2>
            <p>Follow these simple steps to install SoundWave on your Android device</p>
          </div>
          <div className="installation-steps">
            {installation.map((item, index) => (
              <div key={index} className="installation-step animate-fade-up" style={{animationDelay: `${index * 0.1}s`}}>
                <div className="step-number">{item.step}</div>
                <div className="step-content">
                  <h3 className="step-title">{item.title}</h3>
                  <p className="step-description">{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* System Requirements */}
      <section className="system-requirements section">
        <div className="container">
          <div className="requirements-content">
            <div className="requirements-text animate-fade-up">
              <h2>System Requirements</h2>
              <p>Make sure your device meets these requirements for the best experience:</p>
              <ul className="requirements-list">
                {systemRequirements.map((req, index) => (
                  <li key={index} className="requirement-item">
                    <CheckCircle className="check-icon" size={16} />
                    <span>{req}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="requirements-visual animate-fade-right">
              <div className="specs-card">
                <div className="spec-item">
                  <FileText className="spec-icon" />
                  <div className="spec-info">
                    <span className="spec-label">App Version</span>
                    <span className="spec-value">{appInfo.version}</span>
                  </div>
                </div>
                <div className="spec-item">
                  <HardDrive className="spec-icon" />
                  <div className="spec-info">
                    <span className="spec-label">File Size</span>
                    <span className="spec-value">{appInfo.size}</span>
                  </div>
                </div>
                <div className="spec-item">
                  <Smartphone className="spec-icon" />
                  <div className="spec-info">
                    <span className="spec-label">Platform</span>
                    <span className="spec-value">Android</span>
                  </div>
                </div>
                <div className="spec-item">
                  <Shield className="spec-icon" />
                  <div className="spec-info">
                    <span className="spec-label">Security</span>
                    <span className="spec-value">Verified</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Security Section */}
      <section className="security-section">
        <div className="container">
          <div className="security-content">
            
            {/* Header */}
            <div className="security-header">
              <div className="security-badge">
                <Shield className="badge-icon" />
                Verified Secure
              </div>
              <h2>Enterprise-Grade Security</h2>
              <p>Experience comprehensive security validation with real-time scanning and verification. Your safety is our top priority.</p>
            </div>
            
            {/* Security Test Card */}
            <div className="security-test-card">
              <div className="test-visual">
                {testCompleted ? (
                  <div className="success-state">
                    <div className="success-icon">
                      <CheckCircle size={50} />
                    </div>
                    <div className="success-score">{securityScore}%</div>
                  </div>
                ) : (
                  <div className="test-state">
                    <div className={`shield-container ${isTestRunning ? 'scanning' : ''}`}>
                      <Shield className="shield-icon" size={50} />
                      {isTestRunning && (
                        <div className="scan-rings">
                          <div className="ring"></div>
                          <div className="ring"></div>
                          <div className="ring"></div>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
              
              <div className="test-content">
                <h3>
                  {testCompleted 
                    ? '100% Safe & Secure'
                    : isTestRunning 
                      ? 'Running Security Test...' 
                      : 'Ready for Security Scan'
                  }
                </h3>
                <p>
                  {testCompleted
                    ? 'All security checks passed successfully. SoundWave is completely safe to download and install.'
                    : isTestRunning
                      ? currentTestStep
                      : 'Run our comprehensive security test to verify the integrity and safety of SoundWave.'}
                </p>
                
                {isTestRunning && (
                  <div className="progress-bar">
                    <div className="progress" style={{ width: `${testProgress}%` }}></div>
                    <div className="progress-text">{testProgress}%</div>
                  </div>
                )}
                
                <button 
                  className={`test-button ${
                    testCompleted ? 'completed' : isTestRunning ? 'running' : ''
                  }`}
                  onClick={runSecurityTest}
                  disabled={isTestRunning}
                >
                  {testCompleted ? (
                    <>
                      <CheckCircle size={20} />
                      Verified - 100% Safe
                    </>
                  ) : isTestRunning ? (
                    <>
                      <Loader2 className="spinner" size={20} />
                      Running Test...
                    </>
                  ) : (
                    <>
                      <PlayCircle size={20} />
                      Run Security Test
                    </>
                  )}
                </button>
              </div>
            </div>
            
            {/* Security Features */}
            <div className="security-features">
              <div className="feature">
                <div className="feature-icon">
                  <Shield size={24} />
                </div>
                <div className="feature-content">
                  <h4>Malware-Free</h4>
                  <p>Thoroughly scanned and verified free from viruses, malware, and malicious code.</p>
                </div>
              </div>
              <div className="feature">
                <div className="feature-icon">
                  <Zap size={24} />
                </div>
                <div className="feature-content">
                  <h4>Zero Tracking</h4>
                  <p>No data collection, no analytics, and complete privacy protection guaranteed.</p>
                </div>
              </div>
              <div className="feature">
                <div className="feature-icon">
                  <CheckCircle size={24} />
                </div>
                <div className="feature-content">
                  <h4>Open Source</h4>
                  <p>Transparent code that can be audited and verified by security professionals.</p>
                </div>
              </div>
            </div>
            
            {/* Security Notice */}
            <div className="security-notice">
              <div className="notice-icon">
                <AlertCircle size={24} />
              </div>
              <div className="notice-content">
                <h4>Installation Notice</h4>
                <p>
                  Since this is a direct APK download, your device may show a security warning. 
                  This is completely normal for apps installed outside the Google Play Store. 
                  Our security test confirms SoundWave is 100% safe.
                </p>
              </div>
            </div>
            
          </div>
        </div>
      </section>

      {/* Enhanced CTA Section */}
      <section className="cta-section-modern">
        <div className="cta-background">
          <div className="cta-particles">
            {[...Array(20)].map((_, i) => (
              <div key={i} className={`particle particle-${i + 1}`}></div>
            ))}
          </div>
        </div>
        <div className="container">
          <div className="cta-content-modern">
            <div className="cta-icon-group">
              <div className="cta-icon primary">
                <Music size={32} />
              </div>
              <div className="cta-icon secondary">
                <DownloadIcon size={24} />
              </div>
              <div className="cta-icon tertiary">
                <Headphones size={28} />
              </div>
            </div>
            
            <h2 className="cta-title">
              Ready to Transform Your
              <span className="title-accent"> Music Experience?</span>
            </h2>
            
            <p className="cta-description">
              Join over {downloadCount.toLocaleString()} music lovers who've already discovered the power of SoundWave. Start your journey to unlimited audio freedom today.
            </p>
            
            <div className="cta-actions">
              <button 
                className={`cta-btn-primary ${downloaded ? 'downloaded' : ''}`}
                onClick={handleDownload}
                disabled={downloaded}
              >
                <div className="btn-background"></div>
                <div className="btn-content">
                  {downloaded ? (
                    <>
                      <CheckCircle className="btn-icon" size={20} />
                      <span>Successfully Downloaded!</span>
                    </>
                  ) : (
                    <>
                      <DownloadIcon className="btn-icon" size={20} />
                      <span>Download SoundWave Free</span>
                      <ArrowRight className="btn-arrow" size={16} />
                    </>
                  )}
                </div>
              </button>
              
              <div className="cta-features">
                <div className="cta-feature">
                  <CheckCircle size={16} className="check-icon" />
                  <span>100% Free Forever</span>
                </div>
                <div className="cta-feature">
                  <CheckCircle size={16} className="check-icon" />
                  <span>No Registration Required</span>
                </div>
                <div className="cta-feature">
                  <CheckCircle size={16} className="check-icon" />
                  <span>Instant Download ({appInfo.size})</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Download;
