import React, { useState, useEffect } from 'react';
import { 
  Shield, Eye, Lock, Database, CheckCircle, AlertTriangle, 
  FileText, Users, Globe, Cpu, Server, Download,
  Calendar, Mail, ExternalLink, Sparkles, UserX,
  Settings, Trash2, Key, Fingerprint, Bell
} from 'lucide-react';
import './Privacy.css';

const Privacy = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [lastUpdated, setLastUpdated] = useState('August 11, 2025');
  const [expandedSections, setExpandedSections] = useState(new Set());

  useEffect(() => {
    setIsVisible(true);
  }, []);

  const toggleSection = (sectionId) => {
    const newExpandedSections = new Set(expandedSections);
    if (newExpandedSections.has(sectionId)) {
      newExpandedSections.delete(sectionId);
    } else {
      newExpandedSections.add(sectionId);
    }
    setExpandedSections(newExpandedSections);
  };

  return (
    <div className="privacy-page-modern">
      {/* Enhanced Hero Section */}
      <section className="privacy-hero-modern">
        <div className="hero-background">
          <div className="hero-particles">
            {[...Array(10)].map((_, i) => (
              <div key={i} className={`particle particle-${i + 1}`}></div>
            ))}
          </div>
        </div>
        <div className="container">
          <div className="hero-content-modern">
            <div className={`hero-text ${isVisible ? 'animate-fade-up' : ''}`}>
              <div className="hero-badge">
                <Shield size={16} />
                <span>Privacy First</span>
              </div>
              <h1 className="hero-title-modern">
                Your Privacy is Our
                <span className="text-gradient-modern"> Top Priority</span>
              </h1>
              <p className="hero-description-modern">
                We believe privacy is a fundamental right. SoundWave is designed from the ground up to protect your personal information and give you complete control over your data.
              </p>
              
              <div className="privacy-badges">
                <div className="privacy-badge">
                  <UserX size={20} />
                  <span>Zero Data Collection</span>
                </div>
                <div className="privacy-badge">
                  <Eye size={20} />
                  <span>No Tracking</span>
                </div>
                <div className="privacy-badge">
                  <Lock size={20} />
                  <span>Local Processing</span>
                </div>
              </div>
            </div>
            
            <div className={`hero-visual ${isVisible ? 'animate-fade-left' : ''}`}>
              <div className="privacy-showcase">
                <div className="showcase-center">
                  <div className="center-shield">
                    <Shield size={80} />
                  </div>
                  <div className="protection-rings">
                    <div className="protection-ring ring-1"></div>
                    <div className="protection-ring ring-2"></div>
                    <div className="protection-ring ring-3"></div>
                  </div>
                </div>
                
                <div className="floating-privacy-icons">
                  <div className="privacy-icon icon-1">
                    <Lock size={24} />
                  </div>
                  <div className="privacy-icon icon-2">
                    <Eye size={24} />
                  </div>
                  <div className="privacy-icon icon-3">
                    <Database size={24} />
                  </div>
                  <div className="privacy-icon icon-4">
                    <Cpu size={24} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Privacy Principles Section */}
      <section className="privacy-principles-section">
        <div className="container">
          <div className="section-header-modern">
            <div className="header-badge-modern">
              <Sparkles size={16} />
              <span>Core Privacy Principles</span>
            </div>
            <h2 className="section-title-modern">
              How We Protect
              <span className="title-gradient-modern"> Your Digital Rights</span>
            </h2>
            <p className="section-description-modern">
              These fundamental principles guide every decision we make about your privacy and data protection.
            </p>
          </div>
          
          <div className="principles-grid">
            <div className="principle-card">
              <div className="principle-icon-modern zero-data-gradient">
                <UserX size={32} />
              </div>
              <div className="principle-content">
                <h3>Zero Data Collection</h3>
                <p>We don't collect, store, or transmit any personal information. Your identity remains completely anonymous.</p>
                <div className="principle-features">
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>No account registration required</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>No personal data storage</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>No usage analytics</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="principle-card">
              <div className="principle-icon-modern local-processing-gradient">
                <Cpu size={32} />
              </div>
              <div className="principle-content">
                <h3>Local Processing</h3>
                <p>All audio processing happens directly on your device. Your data never leaves your control.</p>
                <div className="principle-features">
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Device-only processing</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>No server uploads</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Offline functionality</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="principle-card">
              <div className="principle-icon-modern transparency-gradient">
                <Eye size={32} />
              </div>
              <div className="principle-content">
                <h3>Complete Transparency</h3>
                <p>Our open-source approach ensures you can verify exactly what our software does.</p>
                <div className="principle-features">
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Open source code</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Public security audits</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Community verification</span>
                  </div>
                </div>
              </div>
            </div>
            
            <div className="principle-card">
              <div className="principle-icon-modern security-gradient">
                <Shield size={32} />
              </div>
              <div className="principle-content">
                <h3>Military-Grade Security</h3>
                <p>We implement the highest security standards to protect you from malware and threats.</p>
                <div className="principle-features">
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Encrypted connections</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Malware protection</span>
                  </div>
                  <div className="feature-item">
                    <CheckCircle size={16} />
                    <span>Regular security updates</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Detailed Privacy Policy Section */}
      <section className="privacy-policy-section">
        <div className="container">
          <div className="policy-header">
            <h2 className="policy-title-modern">
              Detailed Privacy Policy
            </h2>
            <p className="policy-description-modern">
              Complete information about how we handle your privacy and data protection.
            </p>
          </div>
          
          <div className="policy-content-modern">
            <div className="policy-section">
              <div 
                className={`policy-header-clickable ${expandedSections.has('data-collection') ? 'expanded' : ''}`}
                onClick={() => toggleSection('data-collection')}
              >
                <div className="policy-icon-wrapper">
                  <Database size={24} />
                </div>
                <h3>Information We Collect</h3>
                <div className="expand-indicator">+</div>
              </div>
              <div className={`policy-content-expandable ${expandedSections.has('data-collection') ? 'expanded' : ''}`}>
                <div className="policy-text">
                  <h4>The Simple Answer: We Collect Nothing</h4>
                  <p>
                    SoundWave is designed as a privacy-first application. We do not collect, store, process, or transmit any personal information about our users. This includes:
                  </p>
                  <ul>
                    <li>No names, email addresses, or contact information</li>
                    <li>No browsing history or download patterns</li>
                    <li>No device identifiers or fingerprinting</li>
                    <li>No location data or IP address logging</li>
                    <li>No usage analytics or behavioral tracking</li>
                  </ul>
                  
                  <h4>Technical Information</h4>
                  <p>
                    The application processes YouTube URLs locally on your device to extract audio content. This processing happens entirely within the app's sandboxed environment and does not involve sending data to external servers.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="policy-section">
              <div 
                className={`policy-header-clickable ${expandedSections.has('data-usage') ? 'expanded' : ''}`}
                onClick={() => toggleSection('data-usage')}
              >
                <div className="policy-icon-wrapper">
                  <Settings size={24} />
                </div>
                <h3>How We Use Information</h3>
                <div className="expand-indicator">+</div>
              </div>
              <div className={`policy-content-expandable ${expandedSections.has('data-usage') ? 'expanded' : ''}`}>
                <div className="policy-text">
                  <h4>No Data = No Usage</h4>
                  <p>
                    Since we don't collect any personal information, we don't use it for any purpose. The application functions entirely on your device without any need for external data processing or storage.
                  </p>
                  
                  <h4>Local Processing Only</h4>
                  <p>
                    All audio processing, format conversion, and file management happens locally on your device. Your downloaded files remain private and are never uploaded or shared with any third parties.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="policy-section">
              <div 
                className={`policy-header-clickable ${expandedSections.has('data-security') ? 'expanded' : ''}`}
                onClick={() => toggleSection('data-security')}
              >
                <div className="policy-icon-wrapper">
                  <Lock size={24} />
                </div>
                <h3>Data Security & Protection</h3>
                <div className="expand-indicator">+</div>
              </div>
              <div className={`policy-content-expandable ${expandedSections.has('data-security') ? 'expanded' : ''}`}>
                <div className="policy-text">
                  <h4>Security Measures</h4>
                  <p>
                    Even though we don't collect data, we implement robust security measures to protect you:
                  </p>
                  <ul>
                    <li>Encrypted connections for all external requests</li>
                    <li>Code signing and integrity verification</li>
                    <li>Regular security audits and vulnerability assessments</li>
                    <li>Sandboxed execution environment</li>
                    <li>No external dependencies that could compromise privacy</li>
                  </ul>
                  
                  <h4>File Storage</h4>
                  <p>
                    Downloaded files are stored securely in your device's local storage using your operating system's built-in security features. We cannot access these files remotely.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="policy-section">
              <div 
                className={`policy-header-clickable ${expandedSections.has('third-parties') ? 'expanded' : ''}`}
                onClick={() => toggleSection('third-parties')}
              >
                <div className="policy-icon-wrapper">
                  <Users size={24} />
                </div>
                <h3>Third-Party Services</h3>
                <div className="expand-indicator">+</div>
              </div>
              <div className={`policy-content-expandable ${expandedSections.has('third-parties') ? 'expanded' : ''}`}>
                <div className="policy-text">
                  <h4>YouTube Integration</h4>
                  <p>
                    SoundWave interacts with YouTube's public APIs to retrieve audio content. This interaction is governed by YouTube's own privacy policy and terms of service. We do not share any information with YouTube about your usage of our application.
                  </p>
                  
                  <h4>No Analytics Services</h4>
                  <p>
                    We do not use Google Analytics, Facebook Pixel, or any other third-party analytics services that might track your behavior or collect personal information.
                  </p>
                </div>
              </div>
            </div>
            
            <div className="policy-section">
              <div 
                className={`policy-header-clickable ${expandedSections.has('user-rights') ? 'expanded' : ''}`}
                onClick={() => toggleSection('user-rights')}
              >
                <div className="policy-icon-wrapper">
                  <Key size={24} />
                </div>
                <h3>Your Rights & Control</h3>
                <div className="expand-indicator">+</div>
              </div>
              <div className={`policy-content-expandable ${expandedSections.has('user-rights') ? 'expanded' : ''}`}>
                <div className="policy-text">
                  <h4>Complete Control</h4>
                  <p>
                    Since we don't collect any data about you, you maintain complete control over your privacy:
                  </p>
                  <ul>
                    <li>No data to request or export</li>
                    <li>No accounts to delete</li>
                    <li>No tracking to opt out of</li>
                    <li>No personal information to correct</li>
                  </ul>
                  
                  <h4>Uninstall = Complete Removal</h4>
                  <p>
                    Simply uninstalling SoundWave removes all traces of the application from your device. There's no residual data on our servers because we never store any.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
      
      {/* Contact & Updates Section */}
      <section className="privacy-contact-section">
        <div className="container">
          <div className="contact-content-modern">
            <div className="contact-info">
              <h3 className="contact-title">Questions About Privacy?</h3>
              <p className="contact-description">
                We're committed to transparency. If you have any questions about our privacy practices, please don't hesitate to reach out.
              </p>
              
              <div className="contact-methods">
                <a href="mailto:privacy@soundwave.com" className="contact-method">
                  <Mail size={20} />
                  <span>privacy@soundwave.com</span>
                  <ExternalLink size={16} />
                </a>
              </div>
            </div>
            
            <div className="update-info">
              <div className="update-badge">
                <Calendar size={16} />
                <span>Last Updated</span>
              </div>
              <div className="update-date">{lastUpdated}</div>
              <p className="update-note">
                We'll notify users of any material changes to this privacy policy through the application and our website.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Privacy;
