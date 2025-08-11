import React, { useState, useEffect } from 'react';
import { 
  Mail, MessageSquare, HelpCircle, Send, Phone, MapPin, 
  Clock, Globe, Zap, Shield, Users, CheckCircle, 
  ArrowRight, Sparkles, HeartHandshake, MessageCircle,
  Twitter, Github, Linkedin, ExternalLink
} from 'lucide-react';
import './Contact.css';

const Contact = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [responseTime, setResponseTime] = useState('< 4 hours');

  useEffect(() => {
    setIsVisible(true);
    // Simulate dynamic response time
    const interval = setInterval(() => {
      const times = ['< 2 hours', '< 4 hours', '< 1 hour', '< 6 hours'];
      setResponseTime(times[Math.floor(Math.random() * times.length)]);
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    // Simulate form submission
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsSubmitting(false);
    // Reset form or show success message
  };

  return (
    <div className="contact-page-modern">
      {/* Enhanced Hero Section */}
      <section className="contact-hero-modern">
        <div className="hero-background">
          <div className="hero-particles">
            {[...Array(12)].map((_, i) => (
              <div key={i} className={`particle particle-${i + 1}`}></div>
            ))}
          </div>
        </div>
        <div className="container">
          <div className="hero-content-modern">
            <div className={`hero-text ${isVisible ? 'animate-fade-up' : ''}`}>
              <div className="hero-badge">
                <HeartHandshake size={16} />
                <span>We're Here to Help</span>
              </div>
              <h1 className="hero-title-modern">
                Let's Start a
                <span className="text-gradient-modern"> Conversation</span>
              </h1>
              <p className="hero-description-modern">
                Whether you have questions, feedback, or need support, our team is ready to assist you. Your success with SoundWave is our priority.
              </p>
              
              <div className="hero-stats-modern">
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <Clock className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">{responseTime}</div>
                    <div className="stat-label-modern">Avg Response</div>
                  </div>
                </div>
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <Users className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">24/7</div>
                    <div className="stat-label-modern">Support</div>
                  </div>
                </div>
                <div className="stat-modern">
                  <div className="stat-icon-wrapper">
                    <CheckCircle className="stat-icon-modern" />
                  </div>
                  <div className="stat-content">
                    <div className="stat-number-modern">98%</div>
                    <div className="stat-label-modern">Satisfaction</div>
                  </div>
                </div>
              </div>
            </div>
            
            <div className={`hero-visual ${isVisible ? 'animate-fade-left' : ''}`}>
              <div className="visual-showcase">
                <div className="showcase-center">
                  <div className="center-circle">
                    <MessageCircle size={60} />
                  </div>
                  <div className="pulse-rings">
                    <div className="pulse-ring ring-1"></div>
                    <div className="pulse-ring ring-2"></div>
                    <div className="pulse-ring ring-3"></div>
                  </div>
                </div>
                
                <div className="floating-icons">
                  <div className="floating-icon icon-1">
                    <Mail size={24} />
                  </div>
                  <div className="floating-icon icon-2">
                    <MessageSquare size={24} />
                  </div>
                  <div className="floating-icon icon-3">
                    <Phone size={24} />
                  </div>
                  <div className="floating-icon icon-4">
                    <HelpCircle size={24} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Contact Methods Section */}
      <section className="contact-methods-section">
        <div className="container">
          <div className="section-header-modern">
            <div className="header-badge-modern">
              <Sparkles size={16} />
              <span>Multiple Ways to Connect</span>
            </div>
            <h2 className="section-title-modern">
              Choose Your Preferred
              <span className="title-gradient-modern"> Communication Channel</span>
            </h2>
          </div>
          
          <div className="contact-methods-grid">
            <div className="contact-method-card">
              <div className="method-icon-modern email-gradient">
                <Mail size={32} />
              </div>
              <div className="method-content">
                <h3>Email Support</h3>
                <p>Get detailed help via email with our comprehensive support team.</p>
                <div className="method-details">
                  <span className="method-email">hello@soundwave.com</span>
                  <div className="method-stats">
                    <Clock size={14} />
                    <span>Response in {responseTime}</span>
                  </div>
                </div>
                <button className="method-button">
                  <span>Send Email</span>
                  <ExternalLink size={16} />
                </button>
              </div>
            </div>
            
            <div className="contact-method-card">
              <div className="method-icon-modern chat-gradient">
                <MessageSquare size={32} />
              </div>
              <div className="method-content">
                <h3>Live Chat</h3>
                <p>Get instant answers from our support team in real-time.</p>
                <div className="method-details">
                  <span className="method-status">
                    <div className="status-indicator online"></div>
                    Available Now
                  </span>
                  <div className="method-stats">
                    <Users size={14} />
                    <span>3 agents online</span>
                  </div>
                </div>
                <button className="method-button">
                  <span>Start Chat</span>
                  <ArrowRight size={16} />
                </button>
              </div>
            </div>
            
            <div className="contact-method-card">
              <div className="method-icon-modern help-gradient">
                <HelpCircle size={32} />
              </div>
              <div className="method-content">
                <h3>Help Center</h3>
                <p>Browse our comprehensive knowledge base and tutorials.</p>
                <div className="method-details">
                  <span className="method-link">help.soundwave.com</span>
                  <div className="method-stats">
                    <Globe size={14} />
                    <span>500+ articles</span>
                  </div>
                </div>
                <button className="method-button">
                  <span>Browse FAQs</span>
                  <ExternalLink size={16} />
                </button>
              </div>
            </div>
            
            <div className="contact-method-card">
              <div className="method-icon-modern community-gradient">
                <Users size={32} />
              </div>
              <div className="method-content">
                <h3>Community</h3>
                <p>Connect with other users and get peer-to-peer support.</p>
                <div className="method-details">
                  <span className="method-link">community.soundwave.com</span>
                  <div className="method-stats">
                    <MessageCircle size={14} />
                    <span>10k+ members</span>
                  </div>
                </div>
                <button className="method-button">
                  <span>Join Community</span>
                  <ExternalLink size={16} />
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Contact Form Section */}
      <section className="contact-form-section">
        <div className="container">
          <div className="form-content-modern">
            <div className="form-header">
              <h2 className="form-title-modern">
                Send us a Direct Message
              </h2>
              <p className="form-description-modern">
                Have something specific to discuss? Drop us a message and we'll get back to you personally.
              </p>
            </div>
            
            <form className="contact-form-modern" onSubmit={handleSubmit}>
              <div className="form-grid">
                <div className="form-group-modern">
                  <label htmlFor="name" className="form-label-modern">Full Name</label>
                  <input 
                    type="text" 
                    id="name" 
                    name="name" 
                    className="form-input-modern"
                    value={formData.name}
                    onChange={handleInputChange}
                    placeholder="Enter your full name"
                    required 
                  />
                </div>
                
                <div className="form-group-modern">
                  <label htmlFor="email" className="form-label-modern">Email Address</label>
                  <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    className="form-input-modern"
                    value={formData.email}
                    onChange={handleInputChange}
                    placeholder="your@email.com"
                    required 
                  />
                </div>
              </div>
              
              <div className="form-group-modern">
                <label htmlFor="subject" className="form-label-modern">Subject</label>
                <input 
                  type="text" 
                  id="subject" 
                  name="subject" 
                  className="form-input-modern"
                  value={formData.subject}
                  onChange={handleInputChange}
                  placeholder="What's this about?"
                  required 
                />
              </div>
              
              <div className="form-group-modern">
                <label htmlFor="message" className="form-label-modern">Message</label>
                <textarea 
                  id="message" 
                  name="message" 
                  rows="6" 
                  className="form-textarea-modern"
                  value={formData.message}
                  onChange={handleInputChange}
                  placeholder="Tell us more about your question or feedback..."
                  required
                ></textarea>
              </div>
              
              <button 
                type="submit" 
                className={`form-submit-modern ${isSubmitting ? 'submitting' : ''}`}
                disabled={isSubmitting}
              >
                <div className="button-content">
                  {isSubmitting ? (
                    <>
                      <div className="spinner"></div>
                      <span>Sending...</span>
                    </>
                  ) : (
                    <>
                      <Send className="button-icon" size={20} />
                      <span>Send Message</span>
                      <ArrowRight className="button-arrow" size={16} />
                    </>
                  )}
                </div>
                <div className="button-glow"></div>
              </button>
              
              <div className="form-footer">
                <div className="security-note">
                  <Shield size={16} />
                  <span>Your information is secure and will never be shared with third parties.</span>
                </div>
              </div>
            </form>
          </div>
        </div>
      </section>
      
      {/* Social & Additional Contact */}
      <section className="social-contact-section">
        <div className="container">
          <div className="social-content">
            <h3 className="social-title">Connect With Us</h3>
            <p className="social-description">Follow us on social media for updates, tips, and community discussions.</p>
            
            <div className="social-links">
              <a href="#" className="social-link twitter">
                <Twitter size={24} />
                <span>Twitter</span>
              </a>
              <a href="#" className="social-link github">
                <Github size={24} />
                <span>GitHub</span>
              </a>
              <a href="#" className="social-link linkedin">
                <Linkedin size={24} />
                <span>LinkedIn</span>
              </a>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Contact;
