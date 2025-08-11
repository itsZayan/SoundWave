import React, { useState, useEffect } from 'react';
import { 
  Zap, 
  Shield, 
  Headphones, 
  Smartphone,
  Download as DownloadIcon,
  Music,
  Clock,
  HardDrive,
  Wifi,
  Settings,
  Heart,
  Star,
  Code,
  Database,
  Cpu,
  Globe,
  Layers,
  Palette,
  PlayCircle,
  ArrowRight,
  Terminal,
  Sparkles,
  Wrench,
  Lock,
  Gauge,
  Activity,
  Boxes,
  Server,
  Rocket
} from 'lucide-react';
import './Features.css';

const Features = () => {
  const [activeTab, setActiveTab] = useState('app-features');
  const [visibleItems, setVisibleItems] = useState(new Set());
  const [isScanning, setIsScanning] = useState(false);
  const [scanProgress, setScanProgress] = useState(0);
  const [scanComplete, setScanComplete] = useState(false);
  const [showScanResults, setShowScanResults] = useState(false);
  const [currentScan, setCurrentScan] = useState('');

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setVisibleItems((prev) => new Set([...prev, entry.target.dataset.index]));
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('[data-index]');
    elements.forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, [activeTab]);

  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = '/SoundWave.apk';
    link.download = 'SoundWave.apk';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const antivirusEngines = [
    { name: 'Windows Defender', status: 'scanning', progress: 0 },
    { name: 'Avast', status: 'pending', progress: 0 },
    { name: 'Norton', status: 'pending', progress: 0 },
    { name: 'McAfee', status: 'pending', progress: 0 },
    { name: 'Kaspersky', status: 'pending', progress: 0 },
    { name: 'Bitdefender', status: 'pending', progress: 0 },
    { name: 'Malwarebytes', status: 'pending', progress: 0 },
    { name: 'ESET', status: 'pending', progress: 0 }
  ];

  const [scanEngines, setScanEngines] = useState(antivirusEngines);

  const handleSecurityTest = () => {
    if (isScanning) return;
    
    setIsScanning(true);
    setScanProgress(0);
    setScanComplete(false);
    setShowScanResults(false);
    setScanEngines(antivirusEngines);
    setCurrentScan('Initializing security scan...');

    // Start scanning animation
    let progress = 0;
    let currentEngineIndex = 0;
    
    const scanInterval = setInterval(() => {
      progress += Math.random() * 15 + 5;
      
      if (progress >= 100) {
        progress = 100;
        
        // Complete current engine
        setScanEngines(prev => 
          prev.map((engine, index) => {
            if (index === currentEngineIndex) {
              return { ...engine, status: 'complete', progress: 100 };
            }
            if (index === currentEngineIndex + 1 && currentEngineIndex + 1 < antivirusEngines.length) {
              return { ...engine, status: 'scanning', progress: 0 };
            }
            return engine;
          })
        );
        
        currentEngineIndex++;
        progress = 0;
        
        if (currentEngineIndex < antivirusEngines.length) {
          setCurrentScan(`Scanning with ${antivirusEngines[currentEngineIndex].name}...`);
        } else {
          // All engines completed, finalize
          clearInterval(scanInterval);
          setCurrentScan('Finalizing scan results...');
          setScanProgress(100);
          
          setTimeout(() => {
            setScanComplete(true);
            setIsScanning(false);
            setShowScanResults(true);
            setCurrentScan('Security scan complete');
          }, 1500);
          return;
        }
      } else {
        setScanEngines(prev => 
          prev.map((engine, index) => 
            index === currentEngineIndex 
              ? { ...engine, progress }
              : engine
          )
        );
      }
      
      setScanProgress(((currentEngineIndex + (progress / 100)) / antivirusEngines.length) * 100);
    }, 200);
  };

  const tabs = [
    { id: 'app-features', label: 'App Features', icon: <Smartphone size={20} /> },
    { id: 'tech-stack', label: 'Technology', icon: <Code size={20} /> },
    { id: 'architecture', label: 'Architecture', icon: <Database size={20} /> },
    { id: 'performance', label: 'Performance', icon: <Gauge size={20} /> }
  ];

  const appFeatures = [
    {
      icon: <DownloadIcon className="feature-icon" />,
      title: "YouTube Audio Extraction",
      description: "Advanced YouTube-DL integration with custom algorithms for seamless audio extraction from any YouTube video.",
      details: "Our app uses the powerful yt-dlp library (successor to youtube-dl) integrated through RapidAPI services. This ensures reliable extraction of audio streams from YouTube videos while maintaining compliance with platform policies.",
      tech: ["Python yt-dlp", "FFmpeg", "RapidAPI Integration"]
    },
    {
      icon: <Zap className="feature-icon" />,
      title: "Lightning Fast Performance",
      description: "Multi-threaded download engine with parallel processing and smart caching for maximum speed.",
      details: "Built with Flutter's Dart language, leveraging isolates for true multi-threading. Our download engine processes multiple chunks simultaneously while maintaining system stability.",
      tech: ["Dart Isolates", "HTTP/2 Protocol", "Smart Caching"]
    },
    {
      icon: <Shield className="feature-icon" />,
      title: "Enterprise-Grade Security",
      description: "SSL/TLS encryption, secure token management, and privacy-first architecture with no data collection.",
      details: "All network communications are encrypted using TLS 1.3. API keys are stored securely using Android Keystore, and we implement certificate pinning for additional security.",
      tech: ["TLS 1.3 Encryption", "Android Keystore", "Certificate Pinning"]
    },
    {
      icon: <Music className="feature-icon" />,
      title: "Universal Format Support",
      description: "Support for MP3, M4A, AAC, FLAC, and more with real-time format conversion and quality optimization.",
      details: "Integrated FFmpeg library handles audio processing and conversion. Support for various codecs ensures compatibility across all Android devices and media players.",
      tech: ["FFmpeg Library", "Multiple Codecs", "Real-time Conversion"]
    }
  ];

  const techStack = [
    {
      icon: <Code className="tech-icon" />,
      title: "Flutter Framework",
      description: "Built with Flutter 3.19 for native performance across Android devices.",
      details: "Flutter is Google's UI toolkit for building natively compiled applications. It provides excellent performance, hot reload for fast development, and a rich set of customizable widgets. Our app leverages Flutter's Skia graphics engine for smooth 60fps animations and Material Design 3 components for a modern Android experience.",
      benefits: ["Native Performance", "Single Codebase", "Hot Reload", "Material Design 3"]
    },
    {
      icon: <Database className="tech-icon" />,
      title: "Dart Programming Language",
      description: "Powered by Dart's robust type system and async/await patterns.",
      details: "Dart is a client-optimized language for fast apps on any platform. It features strong typing, null safety, and excellent async support. Dart's isolates enable true parallelism for download operations without blocking the UI thread.",
      benefits: ["Null Safety", "Strong Typing", "Async/Await", "Isolates for Threading"]
    },
    {
      icon: <Server className="tech-icon" />,
      title: "RapidAPI Integration",
      description: "Seamless integration with YouTube extraction APIs through RapidAPI marketplace.",
      details: "RapidAPI provides a unified platform for API management and monitoring. We use multiple YouTube extraction APIs through RapidAPI to ensure reliability and redundancy. This approach provides automatic load balancing, detailed analytics, and robust error handling.",
      benefits: ["API Reliability", "Load Balancing", "Analytics", "Error Handling"]
    },
    {
      icon: <Wrench className="tech-icon" />,
      title: "Native Android APIs",
      description: "Deep integration with Android system APIs for optimal user experience.",
      details: "We utilize Android's MediaStore API for file management, NotificationManager for download progress, and WorkManager for background processing. This ensures seamless integration with the Android ecosystem.",
      benefits: ["System Integration", "Background Processing", "File Management", "Notifications"]
    }
  ];

  const architecture = [
    {
      icon: <Layers className="arch-icon" />,
      title: "Clean Architecture Pattern",
      description: "Modular, testable, and maintainable code structure following clean architecture principles.",
      layers: ["Presentation Layer (UI)", "Business Logic Layer", "Data Layer", "External APIs"]
    },
    {
      icon: <Activity className="arch-icon" />,
      title: "State Management",
      description: "Efficient state management using Provider pattern and BLoC architecture.",
      components: ["Provider for State", "BLoC for Business Logic", "Repository Pattern", "Dependency Injection"]
    },
    {
      icon: <Boxes className="arch-icon" />,
      title: "Microservices Integration",
      description: "Distributed architecture with multiple API endpoints for redundancy and performance.",
      services: ["YouTube Extraction API", "Audio Processing Service", "Metadata Retrieval", "Quality Enhancement"]
    }
  ];

  const performance = [
    {
      icon: <Rocket className="perf-icon" />,
      title: "Optimized Performance Metrics",
      description: "Benchmarked performance statistics and optimization techniques.",
      metrics: [
        { label: "App Launch Time", value: "<2 seconds", improvement: "60% faster" },
        { label: "Download Speed", value: "Up to 50MB/s", improvement: "4x faster" },
        { label: "Memory Usage", value: "<100MB RAM", improvement: "50% efficient" },
        { label: "Battery Optimization", value: "Minimal drain", improvement: "Background optimized" }
      ]
    }
  ];
  const mainFeatures = [
    {
      icon: <Zap className="feature-icon" />,
      title: "Lightning Fast Downloads",
      description: "Download your favorite YouTube audio in seconds with our highly optimized download engine. No more waiting around!",
      benefits: ["Parallel download processing", "Smart bandwidth utilization", "Resume interrupted downloads"]
    },
    {
      icon: <Shield className="feature-icon" />,
      title: "100% Safe & Secure",
      description: "Your security is our priority. SoundWave is completely free from malware, ads, and tracking.",
      benefits: ["No malware or viruses", "No data collection", "Secure download protocols"]
    },
    {
      icon: <Headphones className="feature-icon" />,
      title: "Crystal Clear Audio",
      description: "Experience superior audio quality with support for multiple formats and bitrates up to 320kbps.",
      benefits: ["Up to 320kbps quality", "Multiple audio formats", "Lossless conversion"]
    },
    {
      icon: <Smartphone className="feature-icon" />,
      title: "Mobile Optimized",
      description: "Beautiful, intuitive interface designed specifically for mobile devices with touch-first interactions.",
      benefits: ["Touch-optimized UI", "Responsive design", "Gesture controls"]
    }
  ];

  const technicalFeatures = [
    {
      icon: <DownloadIcon className="tech-icon" />,
      title: "Smart Download Engine",
      description: "Advanced download algorithms ensure maximum speed and reliability"
    },
    {
      icon: <Music className="tech-icon" />,
      title: "Format Support",
      description: "Download in MP3, M4A, and other popular audio formats"
    },
    {
      icon: <Clock className="tech-icon" />,
      title: "Background Downloads",
      description: "Continue downloads even when the app is in the background"
    },
    {
      icon: <HardDrive className="tech-icon" />,
      title: "Storage Management",
      description: "Intelligent storage management with automatic cleanup options"
    },
    {
      icon: <Wifi className="tech-icon" />,
      title: "Network Adaptive",
      description: "Automatically adjusts download speed based on connection quality"
    },
    {
      icon: <Settings className="tech-icon" />,
      title: "Customizable Settings",
      description: "Personalize your experience with extensive configuration options"
    }
  ];

  const renderTabContent = () => {
    switch (activeTab) {
      case 'app-features':
        return (
          <div className="tab-content">
            <div className="features-grid">
              {appFeatures.map((feature, index) => (
                <div 
                  key={index} 
                  className={`enhanced-feature-card ${visibleItems.has(index.toString()) ? 'visible' : ''}`}
                  data-index={index}
                >
                  <div className="feature-header">
                    <div className="feature-icon-wrapper">
                      {feature.icon}
                    </div>
                    <div className="feature-content">
                      <h3 className="feature-title">{feature.title}</h3>
                      <p className="feature-description">{feature.description}</p>
                    </div>
                  </div>
                  <div className="feature-details">
                    <p className="feature-explanation">{feature.details}</p>
                    <div className="tech-tags">
                      {feature.tech.map((tech, idx) => (
                        <span key={idx} className="tech-tag">{tech}</span>
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        );
      
      case 'tech-stack':
        return (
          <div className="tab-content">
            <div className="tech-stack-grid">
              {techStack.map((tech, index) => (
                <div 
                  key={index} 
                  className={`tech-stack-card ${visibleItems.has(index.toString()) ? 'visible' : ''}`}
                  data-index={index}
                >
                  <div className="tech-header">
                    <div className="tech-icon-wrapper">
                      {tech.icon}
                    </div>
                    <div>
                      <h3 className="tech-title">{tech.title}</h3>
                      <p className="tech-description">{tech.description}</p>
                    </div>
                  </div>
                  <div className="tech-details">
                    <p className="tech-explanation">{tech.details}</p>
                    <div className="benefits-list">
                      {tech.benefits.map((benefit, idx) => (
                        <div key={idx} className="benefit-item">
                          <Star className="benefit-icon" size={14} />
                          <span>{benefit}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        );
      
      case 'architecture':
        return (
          <div className="tab-content">
            <div className="architecture-grid">
              {architecture.map((arch, index) => (
                <div 
                  key={index} 
                  className={`architecture-card ${visibleItems.has(index.toString()) ? 'visible' : ''}`}
                  data-index={index}
                >
                  <div className="arch-header">
                    <div className="arch-icon-wrapper">
                      {arch.icon}
                    </div>
                    <div>
                      <h3 className="arch-title">{arch.title}</h3>
                      <p className="arch-description">{arch.description}</p>
                    </div>
                  </div>
                  <div className="arch-details">
                    {arch.layers && (
                      <div className="layers-list">
                        {arch.layers.map((layer, idx) => (
                          <div key={idx} className="layer-item">
                            <ArrowRight className="layer-icon" size={16} />
                            <span>{layer}</span>
                          </div>
                        ))}
                      </div>
                    )}
                    {arch.components && (
                      <div className="components-list">
                        {arch.components.map((component, idx) => (
                          <div key={idx} className="component-item">
                            <Cpu className="component-icon" size={16} />
                            <span>{component}</span>
                          </div>
                        ))}
                      </div>
                    )}
                    {arch.services && (
                      <div className="services-list">
                        {arch.services.map((service, idx) => (
                          <div key={idx} className="service-item">
                            <Globe className="service-icon" size={16} />
                            <span>{service}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        );
      
      case 'performance':
        return (
          <div className="tab-content">
            <div className="performance-metrics">
              {performance.map((perf, index) => (
                <div 
                  key={index} 
                  className={`performance-card ${visibleItems.has(index.toString()) ? 'visible' : ''}`}
                  data-index={index}
                >
                  <div className="perf-header">
                    <div className="perf-icon-wrapper">
                      {perf.icon}
                    </div>
                    <div>
                      <h3 className="perf-title">{perf.title}</h3>
                      <p className="perf-description">{perf.description}</p>
                    </div>
                  </div>
                  <div className="metrics-grid">
                    {perf.metrics.map((metric, idx) => (
                      <div key={idx} className="metric-item">
                        <div className="metric-value">{metric.value}</div>
                        <div className="metric-label">{metric.label}</div>
                        <div className="metric-improvement">{metric.improvement}</div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        );
      
      default:
        return null;
    }
  };

  return (
    <div className="features-page">
      {/* Hero Section */}
      <section className="features-hero section">
        <div className="container">
          <div className="hero-content text-center animate-fade-up">
            <div className="hero-badge">
              <Sparkles size={16} />
              <span>Built with Modern Technology</span>
            </div>
            <h1 className="hero-title">
              Advanced Features &
              <span className="text-gradient"> Technical Excellence</span>
            </h1>
            <p className="hero-description">
              Explore the cutting-edge technology powering SoundWave. From Flutter's native performance 
              to advanced YouTube extraction APIs, discover how we've built the ultimate audio downloading experience.
            </p>
            <div className="hero-stats">
              <div className="stat-item">
                <div className="stat-number">Flutter 3.19</div>
                <div className="stat-label">Latest Framework</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">RapidAPI</div>
                <div className="stat-label">Reliable Backend</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">Material 3</div>
                <div className="stat-label">Modern Design</div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Tabbed Content Section */}
      <section className="tabbed-features section">
        <div className="container">
          <div className="tabs-navigation">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                className={`tab-button ${activeTab === tab.id ? 'active' : ''}`}
                onClick={() => setActiveTab(tab.id)}
              >
                {tab.icon}
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
          
          {renderTabContent()}
        </div>
      </section>

      {/* What is Flutter Section */}
      <section className="flutter-explanation section gradient-bg">
        <div className="container">
          <div className="flutter-content">
            <div className="flutter-text animate-fade-up">
              <h2>What is Flutter?</h2>
              <p className="flutter-intro">
                Flutter is Google's revolutionary UI toolkit that allows us to create natively compiled 
                applications for mobile, web, and desktop from a single codebase.
              </p>
              <div className="flutter-benefits">
                <div className="flutter-benefit">
                  <Rocket className="flutter-benefit-icon" />
                  <div>
                    <h4>Native Performance</h4>
                    <p>Compiles to native machine code for 60fps performance</p>
                  </div>
                </div>
                <div className="flutter-benefit">
                  <Palette className="flutter-benefit-icon" />
                  <div>
                    <h4>Beautiful UIs</h4>
                    <p>Rich set of customizable widgets following Material Design</p>
                  </div>
                </div>
                <div className="flutter-benefit">
                  <Terminal className="flutter-benefit-icon" />
                  <div>
                    <h4>Developer Productivity</h4>
                    <p>Hot reload enables instant iteration and faster development</p>
                  </div>
                </div>
                <div className="flutter-benefit">
                  <Globe className="flutter-benefit-icon" />
                  <div>
                    <h4>Cross Platform</h4>
                    <p>Single codebase runs on Android, iOS, web, and desktop</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="flutter-visual animate-fade-left">
              <div className="flutter-diagram">
                <div className="diagram-layer ui-layer">
                  <span>Flutter UI Framework</span>
                </div>
                <div className="diagram-layer dart-layer">
                  <span>Dart Runtime</span>
                </div>
                <div className="diagram-layer engine-layer">
                  <span>Flutter Engine (Skia)</span>
                </div>
                <div className="diagram-layer platform-layer">
                  <span>Android Platform</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Main Features */}
      <section className="main-features section">
        <div className="container">
          <div className="features-grid">
            {mainFeatures.map((feature, index) => (
              <div key={index} className="main-feature-card animate-fade-up" style={{animationDelay: `${index * 0.1}s`}}>
                <div className="feature-header">
                  <div className="feature-icon-wrapper">
                    {feature.icon}
                  </div>
                  <div>
                    <h3 className="feature-title">{feature.title}</h3>
                    <p className="feature-description">{feature.description}</p>
                  </div>
                </div>
                <ul className="feature-benefits">
                  {feature.benefits.map((benefit, idx) => (
                    <li key={idx} className="benefit-item">
                      <Star className="benefit-icon" size={14} />
                      <span>{benefit}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Technical Features */}
      <section className="technical-features section gradient-bg">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Technical Excellence</h2>
            <p>Built with cutting-edge technology for superior performance</p>
          </div>
          <div className="tech-features-grid">
            {technicalFeatures.map((feature, index) => (
              <div key={index} className="tech-feature-card animate-fade-up" style={{animationDelay: `${index * 0.1}s`}}>
                <div className="tech-icon-wrapper">
                  {feature.icon}
                </div>
                <h4 className="tech-feature-title">{feature.title}</h4>
                <p className="tech-feature-description">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Feature Comparison */}
      <section className="feature-comparison section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Why Choose SoundWave?</h2>
            <p>See how we compare to other audio downloaders</p>
          </div>
          <div className="comparison-table animate-fade-up">
            <div className="table-header">
              <div className="feature-col">Feature</div>
              <div className="soundwave-col">SoundWave</div>
              <div className="others-col">Others</div>
            </div>
            <div className="table-row">
              <div className="feature-col">Download Speed</div>
              <div className="soundwave-col success">Ultra Fast</div>
              <div className="others-col">Slow</div>
            </div>
            <div className="table-row">
              <div className="feature-col">Audio Quality</div>
              <div className="soundwave-col success">Up to 320kbps</div>
              <div className="others-col">Limited</div>
            </div>
            <div className="table-row">
              <div className="feature-col">Security</div>
              <div className="soundwave-col success">100% Safe</div>
              <div className="others-col error">Ads/Malware</div>
            </div>
            <div className="table-row">
              <div className="feature-col">User Interface</div>
              <div className="soundwave-col success">Modern & Intuitive</div>
              <div className="others-col">Outdated</div>
            </div>
            <div className="table-row">
              <div className="feature-col">Cost</div>
              <div className="soundwave-col success">100% Free</div>
              <div className="others-col">Paid/Limited</div>
            </div>
          </div>
        </div>
      </section>


      {/* CTA Section */}
      <section className="features-cta section">
        <div className="container">
          <div className="cta-content text-center animate-fade-up">
            <div className="cta-icon-wrapper">
              <DownloadIcon className="cta-icon" size={48} />
            </div>
            <h2>Experience the Technology</h2>
            <p>See how advanced technology translates into a superior user experience</p>
            <div className="cta-buttons">
              <button 
                className="btn btn-primary btn-large"
                onClick={handleDownload}
              >
                <DownloadIcon size={20} />
                Download SoundWave Now
              </button>
              <a 
                href="https://flutter.dev" 
                target="_blank" 
                rel="noopener noreferrer"
                className="btn btn-outline btn-large"
              >
                Learn About Flutter
              </a>
            </div>
            <p className="cta-note">
              Free download • Built with Flutter • Powered by RapidAPI
            </p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Features;
