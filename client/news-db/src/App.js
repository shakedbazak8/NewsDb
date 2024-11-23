import React from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import './App.css';  // Import the CSS file
import Upload from "./Upload";
import Search from "./Search";

// Greeting Component
const Greeting = () => (
  <div className="greeting">
    <h1>Welcome to the NewsDb</h1>
  </div>
);

// Home Component
const Home = () => (
  <div className="page-content">
    <h2>Home Page</h2>
    <p>Welcome to the homepage of NewsDb! Here you'll find the latest updates on world events, tech, sports, and more.</p>
  </div>
);

// Contact Component
const Contact = () => (
  <div className="page-content">
    <h2>Contact Page</h2>
    <p>Have any questions? Get in touch with our team!</p>
  </div>
);

function App() {
  return (
    <Router>
      <div>
        {/* Greeting and Navigation Links */}
        <Greeting />
        <nav>
          <ul>
            <li>
              <Link to="/">Home</Link>
            </li>
            <li>
              <Link to="/upload">Upload</Link>
            </li>
            <li>
              <Link to="/search">Search</Link>
            </li>
            <li>
              <Link to="/contact">Contact</Link>
            </li>
          </ul>
        </nav>

        {/* Define Routes */}
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/upload" element={<Upload />} />
          <Route path="/search" element={<Search />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
