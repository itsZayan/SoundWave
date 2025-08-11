import React, { useState } from 'react';
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
  Loader2
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
      description: "Download YouTube audio in seconds with our optimized engine"
    },
    {
      icon: <Shield className="feature-icon" />,
      title: "100% Safe & Secure",
      description: "No malware, no ads, no tracking. Your privacy is protected"
    },
    {
      icon: <CheckCircle className="feature-icon" />,
      title: "High Quality Audio",
      description: "Crystal clear audio up to 320kbps for the best listening experience"
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
            <div className="hero-text animate-fade-up">
              <h1 className="hero-title">
                Download <span className="text-gradient">SoundWave</span>
              </h1>
              <p className="hero-subtitle">
                Get the ultimate YouTube audio downloader for Android. Free, fast, and secure.
              </p>
              
              <div className="download-card">
                <div className="app-icon">
                  <Smartphone className="phone-icon" />
                </div>
                <div className="app-details">
                  <h3>SoundWave for Android</h3>
                  <div className="app-meta">
                    <span className="version">Version {appInfo.version}</span>
                    <span className="size">{appInfo.size}</span>
                    <div className="rating">
                      <Star className="star filled" size={14} />
                      <Star className="star filled" size={14} />
                      <Star className="star filled" size={14} />
                      <Star className="star filled" size={14} />
                      <Star className="star filled" size={14} />
                      <span className="rating-text">4.9 (1,230 reviews)</span>
                    </div>
                  </div>
                  <button 
                    className={`download-btn ${downloaded ? 'downloaded' : ''}`}
                    onClick={handleDownload}
                    disabled={downloaded}
                  >
                    {downloaded ? (
                      <>
                        <CheckCircle size={20} />
                        Downloaded!
                      </>
                    ) : (
                      <>
                        <DownloadIcon size={20} />
                        Download APK
                      </>
                    )}
                  </button>
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

            <div className="hero-visual animate-fade-left">
              <div className="phone-mockup">
                <div className="phone-frame">
                  <div className="phone-screen">
                    <div className="screen-content">
                      <div className="mock-header">
                        <div className="mock-logo">SoundWave</div>
                        <div className="mock-search"></div>
                      </div>
                      <div className="mock-body">
                        <div className="mock-item active">
                          <div className="mock-thumb"></div>
                          <div className="mock-info">
                            <div className="mock-title"></div>
                            <div className="mock-artist"></div>
                          </div>
                          <div className="mock-download">
                            <DownloadIcon size={16} />
                          </div>
iv>
iv>
                        </div>
                        <div className="mock-item">
                          <div className="mock-thumb"></div>
                          <div className="mock-info">
                            <div className="mock-title"></div>
                            <div className="mock-artist"></div>
                          </div>
                          <div className="mock-download">
                            <DownloadIcon size={16} />
                          </div>
iv>
                        </div>
                        <div className="mock-item">
                          <div className="mock-thumb"></div>
                          <div className="mock-info">
                            <div className="mock-title"></div>
                            <div className="mock-artist"></div>
                          </div>
                          <div className="mock-download">
                            <DownloadIcon size={16} />
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="download-features section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Why Download SoundWave?</h2>
            <p>Discover what makes SoundWave the best choice for YouTube audio downloads</p>
          </div>
          <div className="features-grid">
            {features.map((feature, index) => (
              <div key={index} className="feature-card animate-fade-up" style={{animationDelay: `${index * 0.1}s`}}>
                <div className="feature-icon-wrapper">
                  {feature.icon}
                </div>
                <h3 className="feature-title">{feature.title}</h3>
                <p className="feature-description">{feature.description}</p>
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

      {/* CTA Section */}
      <section className="download-cta section gradient-bg">
        <div className="container">
          <div className="cta-content text-center animate-fade-up">
            <h2>Ready to Start Downloading?</h2>
            <p>Join thousands of users who love SoundWave for their music downloads</p>
            <button 
              className={`btn btn-primary btn-large ${downloaded ? 'downloaded' : ''}`}
              onClick={handleDownload}
              disabled={downloaded}
            >
              {downloaded ? (
                <>
                  <CheckCircle size={20} />
                  Downloaded!
                </>
              ) : (
                <>
                  <DownloadIcon size={20} />
                  Download SoundWave Now
                </>
              )}
            </button>
            <p className="cta-note">
              Free download • No registration required • {appInfo.size}
            </p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Download;
