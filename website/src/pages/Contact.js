import React from 'react';
import { Mail, MessageSquare, HelpCircle, Send } from 'lucide-react';

const Contact = () => {
  return (
    <div className="contact-page">
      <section className="contact-hero section">
        <div className="container">
          <div className="hero-content text-center animate-fade-up">
            <h1 className="hero-title">
              Get in <span className="text-gradient">Touch</span>
            </h1>
            <p className="hero-description">
              Have questions, feedback, or need support? We'd love to hear from you!
            </p>
          </div>
        </div>
      </section>

      <section className="contact-content section">
        <div className="container">
          <div className="contact-grid">
            <div className="contact-info animate-fade-up">
              <h2>Contact Information</h2>
              <div className="contact-methods">
                <div className="contact-method">
                  <Mail className="contact-icon" />
                  <div>
                    <h3>Email Us</h3>
                    <p>hello@soundwave.com</p>
                  </div>
                </div>
                <div className="contact-method">
                  <MessageSquare className="contact-icon" />
                  <div>
                    <h3>Support</h3>
                    <p>support@soundwave.com</p>
                  </div>
                </div>
                <div className="contact-method">
                  <HelpCircle className="contact-icon" />
                  <div>
                    <h3>Help Center</h3>
                    <p>Visit our FAQ section</p>
                  </div>
                </div>
              </div>
            </div>

            <form className="contact-form card animate-fade-up">
              <h2>Send us a Message</h2>
              <div className="form-group">
                <label htmlFor="name">Name</label>
                <input type="text" id="name" name="name" required />
              </div>
              <div className="form-group">
                <label htmlFor="email">Email</label>
                <input type="email" id="email" name="email" required />
              </div>
              <div className="form-group">
                <label htmlFor="subject">Subject</label>
                <input type="text" id="subject" name="subject" required />
              </div>
              <div className="form-group">
                <label htmlFor="message">Message</label>
                <textarea id="message" name="message" rows="5" required></textarea>
              </div>
              <button type="submit" className="btn btn-primary">
                <Send size={18} />
                Send Message
              </button>
            </form>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Contact;
