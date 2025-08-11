import React from 'react';
import { Link } from 'react-router-dom';
import { Music, Mail, Github, Twitter, Instagram, Heart } from 'lucide-react';
import './Footer.css';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="footer-container">
        <div className="footer-content">
          {/* Brand Section */}
          <div className="footer-section">
            <div className="footer-logo">
              <Music className="logo-icon" />
              <span className="logo-text">SoundWave</span>
            </div>
            <p className="footer-description">
              Your ultimate YouTube audio downloader. Experience high-quality music downloads 
              with our modern, intuitive mobile app.
            </p>
            <div className="social-links">
              <a href="#" className="social-link" aria-label="Twitter">
                <Twitter size={20} />
              </a>
              <a href="#" className="social-link" aria-label="Instagram">
                <Instagram size={20} />
              </a>
              <a href="#" className="social-link" aria-label="GitHub">
                <Github size={20} />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="footer-section">
            <h3 className="footer-title">Quick Links</h3>
            <div className="footer-links">
              <Link to="/" className="footer-link">Home</Link>
              <Link to="/features" className="footer-link">Features</Link>
              <Link to="/download" className="footer-link">Download</Link>
              <Link to="/about" className="footer-link">About Us</Link>
            </div>
          </div>

          {/* Support */}
          <div className="footer-section">
            <h3 className="footer-title">Support</h3>
            <div className="footer-links">
              <Link to="/contact" className="footer-link">Contact Us</Link>
              <Link to="/privacy" className="footer-link">Privacy Policy</Link>
              <a href="#" className="footer-link">Terms of Service</a>
              <a href="#" className="footer-link">FAQ</a>
            </div>
          </div>

          {/* Contact */}
          <div className="footer-section">
            <h3 className="footer-title">Get in Touch</h3>
            <div className="contact-info">
              <a href="mailto:hello@soundwave.com" className="contact-link">
                <Mail size={18} />
                hello@soundwave.com
              </a>
              <p className="contact-text">
                Have questions or feedback? We'd love to hear from you!
              </p>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <div className="footer-divider"></div>
          <div className="footer-bottom-content">
            <p className="copyright">
              © {currentYear} SoundWave. All rights reserved.
            </p>
            <p className="made-with-love">
              Made with <Heart size={16} className="heart-icon" /> for music lovers worldwide
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
