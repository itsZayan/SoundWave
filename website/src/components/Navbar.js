import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Download as DownloadIcon } from 'lucide-react';
import './Navbar.css';

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      const isScrolled = window.scrollY > 50;
      setScrolled(isScrolled);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  const closeMenu = () => {
    setIsOpen(false);
  };

  const isActive = (path) => location.pathname === path;

  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = '/SoundWave.apk';
    link.download = 'SoundWave.apk';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <nav className={`navbar ${scrolled ? 'scrolled' : ''}`}>
      <div className="nav-container">
        <Link to="/" className="nav-logo" onClick={closeMenu}>
          <img src="/logo.jpg" alt="SoundWave Logo" className="logo-image" />
          <span className="logo-text">SoundWave</span>
        </Link>

        <div className={`nav-menu ${isOpen ? 'active' : ''}`}>
          <Link
            to="/"
            className={`nav-link ${isActive('/') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            Home
          </Link>
          <Link
            to="/features"
            className={`nav-link ${isActive('/features') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            Features
          </Link>
          <Link
            to="/download"
            className={`nav-link ${isActive('/download') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            Download
          </Link>
          <Link
            to="/about"
            className={`nav-link ${isActive('/about') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            About
          </Link>
          <Link
            to="/contact"
            className={`nav-link ${isActive('/contact') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            Contact
          </Link>
          <Link
            to="/privacy"
            className={`nav-link ${isActive('/privacy') ? 'active' : ''}`}
            onClick={closeMenu}
          >
            Privacy
          </Link>
          <button
            className="nav-cta btn btn-primary"
            onClick={() => { handleDownload(); closeMenu(); }}
          >
            <DownloadIcon size={18} />
            Get App
          </button>
        </div>

        <div className="nav-toggle" onClick={toggleMenu}>
          {isOpen ? <X size={24} /> : <Menu size={24} />}
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
