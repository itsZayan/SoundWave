import React from 'react';
import { Users, Target, Award, Heart, Download } from 'lucide-react';
import { Link } from 'react-router-dom';

const About = () => {
  return (
    <div className="about-page">
      <section className="about-hero section">
        <div className="container">
          <div className="hero-content text-center animate-fade-up">
            <h1 className="hero-title">
              About <span className="text-gradient">SoundWave</span>
            </h1>
            <p className="hero-description">
              We're passionate about making music accessible to everyone. SoundWave was born 
              from the simple idea that downloading your favorite audio should be fast, safe, and effortless.
            </p>
          </div>
        </div>
      </section>

      <section className="mission section">
        <div className="container">
          <div className="mission-content">
            <div className="mission-text animate-fade-up">
              <h2>Our Mission</h2>
              <p>
                To provide the world's best YouTube audio downloading experience through 
                innovative technology, beautiful design, and unwavering commitment to user privacy.
              </p>
            </div>
            <div className="mission-stats">
              <div className="stat-card animate-fade-up">
                <Users className="stat-icon" />
                <div className="stat-info">
                  <span className="stat-number">50K+</span>
                  <span className="stat-label">Happy Users</span>
                </div>
              </div>
              <div className="stat-card animate-fade-up">
                <Download className="stat-icon" />
                <div className="stat-info">
                  <span className="stat-number">1M+</span>
                  <span className="stat-label">Downloads</span>
                </div>
              </div>
              <div className="stat-card animate-fade-up">
                <Award className="stat-icon" />
                <div className="stat-info">
                  <span className="stat-number">4.9</span>
                  <span className="stat-label">Rating</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="values section gradient-bg">
        <div className="container">
          <div className="section-header text-center animate-fade-up">
            <h2>Our Values</h2>
            <p>The principles that guide everything we do</p>
          </div>
          <div className="values-grid">
            <div className="value-card animate-fade-up">
              <Target className="value-icon" />
              <h3>Innovation</h3>
              <p>We constantly push the boundaries of what's possible in audio downloading technology.</p>
            </div>
            <div className="value-card animate-fade-up">
              <Heart className="value-icon" />
              <h3>User First</h3>
              <p>Every decision we make is centered around providing the best possible user experience.</p>
            </div>
            <div className="value-card animate-fade-up">
              <Award className="value-icon" />
              <h3>Quality</h3>
              <p>We never compromise on quality, delivering crystal-clear audio and reliable performance.</p>
            </div>
          </div>
        </div>
      </section>

      <section className="cta section">
        <div className="container">
          <div className="cta-content text-center animate-fade-up">
            <h2>Ready to Join Our Community?</h2>
            <p>Experience the SoundWave difference today</p>
            <Link to="/download" className="btn btn-primary btn-large">
              <Download size={20} />
              Download SoundWave
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default About;
