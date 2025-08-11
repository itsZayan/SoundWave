# SoundWave Website

A modern, responsive React website for the SoundWave YouTube audio downloader app.

## 🚀 Features

- **Modern Design**: Beautiful, dark-themed UI with gradient accents matching the app's branding
- **Fully Responsive**: Optimized for all devices from mobile to desktop
- **Multi-page Layout**: Complete website with Home, Features, Download, About, Contact, and Privacy pages
- **Interactive Elements**: Smooth animations, hover effects, and engaging user interactions
- **APK Download**: Direct download functionality for the Android APK
- **SEO Optimized**: Meta tags, Open Graph, and Twitter Card support

## 📱 Pages

1. **Home** - Hero section with app showcase, features, testimonials, and statistics
2. **Features** - Detailed feature breakdown and comparison table
3. **Download** - APK download page with installation guide and system requirements
4. **About** - Company mission, values, and statistics
5. **Contact** - Contact form and information
6. **Privacy** - Privacy policy and data protection information

## 🛠️ Tech Stack

- **React 18** - Modern React with hooks and functional components
- **React Router DOM** - Client-side routing
- **Lucide React** - Beautiful icon library
- **Framer Motion** - Smooth animations and transitions
- **CSS Custom Properties** - Consistent theming and styling
- **Responsive Design** - Mobile-first approach

## 🎨 Design Features

- **SoundWave Branding**: Purple gradient theme (#8E44AD to #9B59B6)
- **Dark Theme**: Modern dark UI with proper contrast ratios
- **Glassmorphism Effects**: Backdrop blur and transparency effects
- **Smooth Animations**: Fade-in, slide, and floating animations
- **Interactive Components**: Hover states and micro-interactions

## 📦 Installation

1. Navigate to the website directory:
   ```bash
   cd website
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

4. Build for production:
   ```bash
   npm run build
   ```

## 📁 Project Structure

```
website/
├── public/
│   ├── index.html
│   └── manifest.json
├── src/
│   ├── components/
│   │   ├── Navbar.js
│   │   ├── Navbar.css
│   │   ├── Footer.js
│   │   └── Footer.css
│   ├── pages/
│   │   ├── Home.js
│   │   ├── Home.css
│   │   ├── Download.js
│   │   ├── Download.css
│   │   ├── Features.js
│   │   ├── About.js
│   │   ├── Contact.js
│   │   └── Privacy.js
│   ├── App.js
│   ├── App.css
│   └── index.js
├── package.json
└── README.md
```

## 🌟 Key Components

### Navigation
- Fixed header with smooth scroll effects
- Mobile-responsive hamburger menu
- Active page indicators
- Smooth transitions

### Hero Section
- Animated phone mockup showing the app interface
- Floating elements with CSS animations
- Statistics display
- Call-to-action buttons

### Download Section
- Direct APK download functionality
- App information display (version, size, ratings)
- Installation guide with step-by-step instructions
- System requirements
- Security notices

### Features Showcase
- Feature cards with hover effects
- Comparison table
- Technical specifications
- Benefits highlighting

## 🎯 Performance

- Optimized bundle size
- Lazy loading for images
- Efficient CSS with custom properties
- Smooth 60fps animations
- SEO-friendly structure

## 📱 Mobile Optimization

- Touch-friendly interface
- Responsive typography
- Optimized images
- Fast loading times
- Gesture support

## 🔧 Customization

The website uses CSS custom properties for easy theming:

```css
:root {
  --primary-color: #8E44AD;
  --primary-accent: #9B59B6;
  --secondary-color: #3498DB;
  --dark-bg: #121212;
  --dark-surface: #1E1E1E;
  /* ... more variables */
}
```

## 🚀 Deployment

The website is ready for deployment on any static hosting platform:

- **Netlify**: Drag and drop the `build` folder
- **Vercel**: Connect GitHub repository for automatic deployments
- **GitHub Pages**: Enable Pages in repository settings
- **Firebase Hosting**: Use Firebase CLI

## 📄 License

This project is part of the SoundWave application suite. All rights reserved.

## 🤝 Contributing

This website was created as part of the SoundWave project. For contributions or issues, please refer to the main project repository.

---

**Note**: Make sure to update the APK download path in `Download.js` to point to the correct location of your built APK file.
