import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Download, 
  Music, 
  Zap, 
  Shield, 
  Headphones, 
  Smartphone,
  Star,
  CheckCircle,
  Play,
  ArrowRight,
  Sparkles,
  Globe,
  Users,
  Award,
  Layers,
  TrendingUp,
  Heart,
  Clock,
  Wifi
} from 'lucide-react';
import SoundWaveAppReplica from '../components/SoundWaveAppReplica';
import './Home.css';

const Home = () => {
  const [currentStat, setCurrentStat] = useState(0);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentStat((prev) => (prev + 1) % 4);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const features = [
    {
      icon: <Zap className="feature-icon" />,
      title: "Lightning Fast",
      description: "Download your favorite YouTube audio in seconds with our optimized engine."
    },
    {
      icon: <Shield className="feature-icon" />,
      title: "100% Safe",
      description: "Secure downloads with no malware or unwanted software. Your device stays protected."
    },
    {
      icon: <Headphones className="feature-icon" />,
      title: "High Quality",
      description: "Crystal clear audio quality up to 320kbps. Experience music as it's meant to be."
    },
    {
      icon: <Smartphone className="feature-icon" />,
      title: "Mobile First",
      description: "Beautiful, intuitive mobile interface designed for the modern user experience."
    }
  ];

  const testimonials = [
    {
      name: "Sarah Johnson",
      role: "Music Enthusiast",
      content: "SoundWave has completely changed how I listen to music. The quality is incredible and the app is so easy to use!",
      rating: 5
    },
    {
      name: "Mike Chen",
      role: "Content Creator",
      content: "As a content creator, I need reliable audio downloads. SoundWave delivers every time with perfect quality.",
      rating: 5
    },
    {
      name: "Emma Davis",
      role: "Student",
      content: "Perfect for creating study playlists! The download speed is amazing and the interface is beautiful.",
      rating: 5
    }
  ];

  const stats = [
    { number: "1M+", label: "Downloads", icon: <Download size={20} />, description: "Total downloads across all platforms" },
    { number: "50K+", label: "Active Users", icon: <Users size={20} />, description: "Daily active users worldwide" },
    { number: "4.9", label: "App Rating", icon: <Star size={20} />, description: "Average rating on app stores" },
    { number: "99.9%", label: "Uptime", icon: <Wifi size={20} />, description: "Service reliability guarantee" }
  ];

  const premiumFeatures = [
    {
      icon: <Sparkles className="premium-icon" />,
      title: "AI-Powered Quality Enhancement",
      description: "Our advanced AI algorithms automatically enhance audio quality for the best possible listening experience.",
      badge: "NEW"
    },
    {
      icon: <Globe className="premium-icon" />,
      title: "Global CDN Network",
      description: "Download from the fastest servers worldwide with our distributed content delivery network.",
      badge: "FAST"
    },
    {
      icon: <Award className="premium-icon" />,
      title: "Award-Winning Interface",
      description: "Recognized for best mobile app design with an intuitive, user-friendly interface.",
      badge: "AWARD"
    },
    {
      icon: <TrendingUp className="premium-icon" />,
      title: "Smart Download Queue",
      description: "Intelligent batch processing that optimizes download order for maximum efficiency.",
      badge: "SMART"
    },
    {
      icon: <Heart className="premium-icon" />,
      title: "Favorite Playlists",
      description: "Create and manage your favorite music collections with our built-in playlist manager.",
      badge: "POPULAR"
    },
    {
      icon: <Clock className="premium-icon" />,
      title: "Instant Processing",
      description: "Lightning-fast processing that converts and downloads your audio in record time.",
      badge: "INSTANT"
    }
  ];

  const benefits = [
    {
      title: "Completely Free",
      description: "No hidden costs, no subscriptions, no premium tiers. SoundWave is 100% free forever.",
      icon: <CheckCircle className="benefit-icon" />,
      color: "green"
    },
    {
      title: "No Registration Required",
      description: "Start downloading immediately without creating accounts or providing personal information.",
      icon: <Users className="benefit-icon" />,
      color: "blue"
    },
    {
      title: "Multi-Format Support",
      description: "Download in various audio formats including MP3, MP4, WAV, and more with quality up to 320kbps.",
      icon: <Layers className="benefit-icon" />,
      color: "purple"
    },
    {
      title: "Cross-Platform Compatibility",
      description: "Works seamlessly on Android, iOS, Windows, Mac, and Linux. One app, all platforms.",
      icon: <Smartphone className="benefit-icon" />,
      color: "orange"
    }
  ];

  return (
    <div className="home">
      {/* Hero Section */}
      <section className="hero">
        <div className="hero-container">
          <div className="hero-content">
            <div className="hero-text animate-fade-up">
              <h1 className="hero-title">
                Your Ultimate
                <span className="text-gradient"> YouTube Audio </span>
                Downloader
              </h1>
              <p className="hero-description">
                Experience lightning-fast, high-quality audio downloads from YouTube. 
                SoundWave delivers crystal-clear music with our modern, intuitive mobile app.
              </p>
              <div className="hero-buttons">
                <Link to="/download" className="btn btn-primary btn-large">
                  <Download size={20} />
                  Download Now
                </Link>
                <Link to="/features" className="btn btn-outline btn-large">
                  <Play size={20} />
                  See Features
                </Link>
              </div>
              <div className="hero-stats">
                {stats.map((stat, index) => (
                  <div key={index} className="stat-item">
                    <span className="stat-number">{stat.number}</span>
                    <span className="stat-label">{stat.label}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="hero-visual animate-fade-right">
              <SoundWaveAppReplica />
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Stats Showcase */}
      <section className="stats-showcase section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Trusted by Millions Worldwide</h2>
            <p>Join our growing community of music lovers and content creators</p>
          </div>
          <div className="stats-grid">
            {stats.map((stat, index) => (
              <div key={index} className={`stat-card animate-fade-up ${index === currentStat ? 'active' : ''}`} style={{animationDelay: `${index * 0.1}s`}}>
                <div className="stat-icon">
                  {stat.icon}
                </div>
                <span className="stat-number">{stat.number}</span>
                <span className="stat-label">{stat.label}</span>
                <div className="stat-description">
                  {stat.description}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Why Choose SoundWave?</h2>
            <p>Discover the features that make SoundWave the best YouTube audio downloader</p>
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

      {/* Premium Features Showcase */}
      <section className="premium-showcase section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Next-Generation Features</h2>
            <p>Experience cutting-edge technology that sets SoundWave apart from the competition</p>
          </div>
          <div className="premium-grid">
            {premiumFeatures.map((feature, index) => (
              <div key={index} className="premium-card animate-fade-up" style={{animationDelay: `${index * 0.1}s`}}>
                <div className="badge badge-{feature.badge.toLowerCase()}">{feature.badge}</div>
                <div className="premium-header">
                  {feature.icon}
                  <h3>{feature.title}</h3>
                </div>
                <p>{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="how-it-works section gradient-bg">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>How It Works</h2>
            <p>Get your favorite music in just three simple steps</p>
          </div>
          <div className="steps-container">
            <div className="step animate-fade-up">
              <div className="step-number">1</div>
              <div className="step-content">
                <h3>Paste YouTube Link</h3>
                <p>Copy and paste any YouTube video URL into the SoundWave app</p>
              </div>
            </div>
            <div className="step-arrow">
              <ArrowRight size={24} />
            </div>
            <div className="step animate-fade-up">
              <div className="step-number">2</div>
              <div className="step-content">
                <h3>Choose Quality</h3>
                <p>Select your preferred audio quality up to 320kbps for the best experience</p>
              </div>
            </div>
            <div className="step-arrow">
              <ArrowRight size={24} />
            </div>
            <div className="step animate-fade-up">
              <div className="step-number">3</div>
              <div className="step-content">
                <h3>Download & Enjoy</h3>
                <p>Your high-quality audio file is ready in seconds. Enjoy your music!</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Benefits Section */}
      <section className="benefits-section section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Everything You Need. Nothing You Don't.</h2>
            <p>Experience the perfect balance of simplicity and power</p>
          </div>
          <div className="benefits-grid">
            {benefits.map((benefit, index) => (
              <div key={index} className="benefit-card animate-fade-up" style={{animationDelay: `${index * 0.15}s`}}>
                {benefit.icon}
                <h3>{benefit.title}</h3>
                <p>{benefit.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="testimonials section">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>What Our Users Say</h2>
            <p>Join thousands of satisfied users who love SoundWave</p>
          </div>
          <div className="testimonials-grid">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="testimonial-card animate-fade-up" style={{animationDelay: `${index * 0.2}s`}}>
                <div className="testimonial-rating">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="star-icon filled" size={16} />
                  ))}
                </div>
                <p className="testimonial-content">"{testimonial.content}"</p>
                <div className="testimonial-author">
                  <div className="author-info">
                    <h4 className="author-name">{testimonial.name}</h4>
                    <p className="author-role">{testimonial.role}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="cta section gradient-bg">
        <div className="container">
          <div className="cta-content text-center animate-fade-up">
            <h2>Ready to Transform Your Music Experience?</h2>
            <p>Join millions of music lovers who trust SoundWave for their audio downloads</p>
            <div className="cta-buttons">
              <Link to="/download" className="btn btn-primary btn-large">
                <Download size={20} />
                Download SoundWave
              </Link>
              <Link to="/features" className="btn btn-outline btn-large">
                Learn More
              </Link>
            </div>
            <div className="cta-features">
              <div className="cta-feature">
                <CheckCircle size={16} />
                <span>100% Free</span>
              </div>
              <div className="cta-feature">
                <CheckCircle size={16} />
                <span>No Registration</span>
              </div>
              <div className="cta-feature">
                <CheckCircle size={16} />
                <span>High Quality</span>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
