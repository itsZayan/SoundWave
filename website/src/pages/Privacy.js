import React from 'react';
import { Shield, Eye, Lock, Database } from 'lucide-react';

const Privacy = () => {
  return (
    <div className="privacy-page">
      <section className="privacy-hero section">
        <div className="container">
          <div className="hero-content text-center animate-fade-up">
            <h1 className="hero-title">
              Privacy <span className="text-gradient">Policy</span>
            </h1>
            <p className="hero-description">
              Your privacy is important to us. Learn how we protect your data and respect your privacy.
            </p>
          </div>
        </div>
      </section>

      <section className="privacy-content section">
        <div className="container">
          <div className="privacy-highlights">
            <div className="highlight-card animate-fade-up">
              <Shield className="highlight-icon" />
              <h3>No Data Collection</h3>
              <p>We don't collect or store your personal information</p>
            </div>
            <div className="highlight-card animate-fade-up">
              <Eye className="highlight-icon" />
              <h3>No Tracking</h3>
              <p>We don't track your downloads or usage patterns</p>
            </div>
            <div className="highlight-card animate-fade-up">
              <Lock className="highlight-icon" />
              <h3>Secure Downloads</h3>
              <p>All downloads are processed securely on your device</p>
            </div>
            <div className="highlight-card animate-fade-up">
              <Database className="highlight-icon" />
              <h3>Local Storage</h3>
              <p>Downloaded files are stored locally on your device only</p>
            </div>
          </div>

          <div className="privacy-text animate-fade-up">
            <h2>What Information We Collect</h2>
            <p>
              SoundWave is designed with privacy in mind. We do not collect, store, or transmit 
              any personal information. The app processes YouTube URLs locally on your device 
              to provide download functionality.
            </p>

            <h2>How We Use Information</h2>
            <p>
              Since we don't collect personal information, we don't use it for any purpose. 
              The app functions entirely on your device without sending data to our servers.
            </p>

            <h2>Data Security</h2>
            <p>
              Your downloaded files are stored securely on your device's local storage. 
              We use industry-standard security measures to ensure the app itself is safe from malware.
            </p>

            <h2>Contact Us</h2>
            <p>
              If you have any questions about this Privacy Policy, please contact us at 
              privacy@soundwave.com
            </p>

            <p className="last-updated">
              Last updated: August 10, 2025
            </p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Privacy;
