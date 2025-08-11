import React, { useState, useEffect } from 'react';
import { 
  Users, Target, Award, Heart, Download, Music, Headphones, 
  Globe, Zap, Shield, Code, Sparkles, TrendingUp, 
  CheckCircle, Star, ArrowRight, Play, Volume2,
  Smartphone, Cpu, Database, Lock, Eye
} from 'lucide-react';
import { Link } from 'react-router-dom';
import './About.css';

const About = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [userCount, setUserCount] = useState(127500);
  const [downloadCount, setDownloadCount] = useState(2450000);

  useEffect(() => {
    setIsVisible(true);
    // Animate counters
    const interval = setInterval(() => {
      setUserCount(prev => prev + Math.floor(Math.random() * 5));
      setDownloadCount(prev => prev + Math.floor(Math.random() * 20));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="about-page-modern">
      {/* Enhanced Hero Section */}
      <section className="about-hero-modern">
        <div className="hero-background">
          <div className="hero-particles">
            {[...Array(15)].map((_, i) => (
              <div key={i} className={`particle particle-${i + 1}`}></div>
            ))}
          </div>
        </div>
        <div className="container">
          <div className="hero-content-modern">
            <div className={`hero-text ${isVisible ? 'animate-fade-up' : ''}`}>
              <div className="hero-badge">
                <Sparkles size={16} />
                <span>Revolutionary Audio Technology</span>
              </div>
              <h1 className="hero-title-modern">
                Redefining Audio
                <span className="text-gradient-modern"> Downloads Forever</span>
              </h1>
              <p className="hero-description-modern">
                Born from a passion for music and technology, SoundWave represents the next evolution in audio downloading. We've reimagined what's possible when innovation meets user experience.
              </p>
              
              <div className="hero-stats-modern">
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <Users className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">{userCount.toLocaleString()}+</div>
                    <div className="stat-label-modern">Global Users</div>
                  </div>
                </div>
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <Download className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">{downloadCount.toLocaleString()}+</div>
                    <div className="stat-label-modern">Downloads</div>
                  </div>
                </div>
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <Star className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">4.9</div>
                    <div className="stat-label-modern">Rating</div>
                  </div>
                </div>
              </div>
            </div>
            
            <div className={`hero-visual ${isVisible ? 'animate-fade-left' : ''}`}>
              <div className="visual-showcase">
                <div className="showcase-center">
                  <div className="center-circle">
                    <Music size={60} />
                  </div>
                  <div className="pulse-rings">
                    <div className="pulse-ring ring-1"></div>
                    <div className="pulse-ring ring-2"></div>
                    <div className="pulse-ring ring-3"></div>
                  </div>
                </div>
                
                <div className="floating-icons">
                  <div className="floating-icon icon-1">
                    <Headphones size={24} />
                  </div>
                  <div className="floating-icon icon-2">
                    <Volume2 size={24} />
                  </div>
                  <div className="floating-icon icon-3">
                    <Play size={24} />
                  </div>
                  <div className="floating-icon icon-4">
                    <Smartphone size={24} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Mission & Story Section */}
      <section className="mission-section-modern">
        <div className="container">
          <div className="mission-content-modern">
            <div className="mission-story">
              <div className="story-badge">
                <Target size={16} />
                <span>Our Mission</span>
              </div>
              <h2 className="mission-title">
                Democratizing Access to
                <span className="title-accent"> High-Quality Audio</span>
              </h2>
              <p className="mission-description">
                We believe everyone deserves access to their favorite music, anytime, anywhere. SoundWave was created to break down the barriers between you and the audio content you love, providing a seamless, secure, and lightning-fast downloading experience.
              </p>
              
              <div className="mission-features">
                <div className="mission-feature">
                  <CheckCircle className="feature-check" size={20} />
                  <span>Privacy-first approach with zero data collection</span>
                </div>
                <div className="mission-feature">
                  <CheckCircle className="feature-check" size={20} />
                  <span>Open-source technology for complete transparency</span>
                </div>
                <div className="mission-feature">
                  <CheckCircle className="feature-check" size={20} />
                  <span>Cutting-edge algorithms for optimal performance</span>
                </div>
              </div>
              
              <div className="story-timeline">
                <div className="timeline-item">
                  <div className="timeline-year">2024</div>
                  <div className="timeline-content">
                    <h4>The Vision</h4>
                    <p>Started with a simple idea: make audio downloading effortless</p>
                  </div>
                </div>
                <div className="timeline-item">
                  <div className="timeline-year">2025</div>
                  <div className="timeline-content">
                    <h4>The Launch</h4>
                    <p>Released SoundWave to the world with unprecedented features</p>
                  </div>
                </div>
                <div className="timeline-item">
                  <div className="timeline-year">Now</div>
                  <div className="timeline-content">
                    <h4>The Future</h4>
                    <p>Continuously evolving with AI-powered enhancements</p>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="mission-visual">
              <div className="tech-showcase">
                <div className="tech-item">
                  <Cpu className="tech-icon" />
                  <div className="tech-label">AI-Powered</div>
                </div>
                <div className="tech-item">
                  <Shield className="tech-icon" />
                  <div className="tech-label">Secure</div>
                </div>
                <div className="tech-item">
                  <Zap className="tech-icon" />
                  <div className="tech-label">Lightning Fast</div>
                </div>
                <div className="tech-item">
                  <Database className="tech-icon" />
                  <div className="tech-label">Local Processing</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Values Section */}
      <section className="values-section-modern">
        <div className="container">
          <div className="section-header-modern">
            <div className="header-badge-modern">
              <Heart size={16} />
              <span>Core Values</span>
            </div>
            <h2 className="section-title-modern">
              The Principles That
              <span className="title-gradient-modern"> Drive Our Innovation</span>
            </h2>
            <p className="section-description-modern">
              Every line of code, every design decision, and every feature is guided by these fundamental beliefs.
            </p>
          </div>
          
          <div className="values-grid-modern">
            <div className="value-card-modern">
              <div className="value-icon-modern innovation-gradient">
                <Target size={32} />
              </div>
              <div className="value-content-modern">
                <h3>Relentless Innovation</h3>
                <p>We push the boundaries of what's possible, continuously reimagining audio technology to stay ahead of tomorrow's needs.</p>
                <div className="value-metrics">
                  <div className="metric">
                    <TrendingUp size={16} />
                    <span>300% faster processing</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="value-card-modern">
              <div className="value-icon-modern user-gradient">
                <Heart size={32} />
              </div>
              <div className="value-content-modern">
                <h3>User-Centric Design</h3>
                <p>Every pixel serves a purpose. We craft experiences that feel intuitive, delightful, and effortlessly powerful.</p>
                <div className="value-metrics">
                  <div className="metric">
                    <Star size={16} />
                    <span>4.9/5 user satisfaction</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="value-card-modern">
              <div className="value-icon-modern quality-gradient">
                <Award size={32} />
              </div>
              <div className="value-content-modern">
                <h3>Uncompromising Quality</h3>
                <p>From 320kbps crystal-clear audio to military-grade security, we never settle for "good enough."</p>
                <div className="value-metrics">
                  <div className="metric">
                    <Shield size={16} />
                    <span>100% malware-free</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="value-card-modern">
              <div className="value-icon-modern privacy-gradient">
                <Lock size={32} />
              </div>
              <div className="value-content-modern">
                <h3>Privacy by Design</h3>
                <p>Your data belongs to you. We built SoundWave to operate entirely on your device with zero tracking.</p>
                <div className="value-metrics">
                  <div className="metric">
                    <Eye size={16} />
                    <span>Zero data collection</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="value-card-modern">
              <div className="value-icon-modern global-gradient">
                <Globe size={32} />
              </div>
              <div className="value-content-modern">
                <h3>Global Accessibility</h3>
                <p>Music transcends borders. We're building technology that works seamlessly across cultures and devices.</p>
                <div className="value-metrics">
                  <div className="metric">
                    <Users size={16} />
                    <span>50+ countries served</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="value-card-modern">
              <div className="value-icon-modern code-gradient">
                <Code size={32} />
              </div>
              <div className="value-content-modern">
                <h3>Open Innovation</h3>
                <p>Transparency builds trust. Our open-source approach ensures accountability and community-driven improvement.</p>
                <div className="value-metrics">
                  <div className="metric">
                    <CheckCircle size={16} />
                    <span>Community audited</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Enhanced CTA Section */}
      <section className="about-cta-modern">
        <div className="cta-background-modern">
          <div className="cta-gradient"></div>
        </div>
        <div className="container">
          <div className="cta-content-modern">
            <div className="cta-icon-cluster">
              <div className="cluster-icon primary">
                <Music size={28} />
              </div>
              <div className="cluster-icon secondary">
                <Download size={24} />
              </div>
              <div className="cluster-icon tertiary">
                <Headphones size={26} />
              </div>
            </div>
            
            <h2 className="cta-title-modern">
              Ready to Experience the
              <span className="title-highlight"> Future of Audio?</span>
            </h2>
            
            <p className="cta-description-modern">
              Join over {userCount.toLocaleString()} users who've already discovered what makes SoundWave extraordinary. Your journey to unlimited audio freedom starts here.
            </p>
            
            <div className="cta-actions-modern">
              <Link to="/download" className="cta-button-primary">
                <div className="button-content">
                  <Download className="button-icon" size={20} />
                  <span>Download SoundWave</span>
                  <ArrowRight className="button-arrow" size={16} />
                </div>
                <div className="button-glow"></div>
              </Link>
              
              <div className="cta-trust-indicators">
                <div className="trust-item">
                  <Shield size={16} />
                  <span>100% Safe & Secure</span>
                </div>
                <div className="trust-item">
                  <CheckCircle size={16} />
                  <span>No Registration Required</span>
                </div>
                <div className="trust-item">
                  <Star size={16} />
                  <span>Rated 4.9/5 by Users</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default About;
