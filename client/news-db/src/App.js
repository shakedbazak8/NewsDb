import React from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import './App.css';  // Import the CSS file
import Upload from "./Upload";
import Search from "./Search";
import WordGroup from "./WordGroup";
import Phrases from "./Phrases";
import Words from "./Words";
import Home from "./Home";

// Greeting Component
const Greeting = () => (
  <div className="greeting">
    <h1>Welcome to the NewsDb</h1>
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
              <Link to="/word-group">Word Group</Link>
            </li>
            <li>
              <Link to="/phrase">Phrase</Link>
            </li>
            <li>
              <Link to="/words">Words</Link>
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
          <Route path="/word-group" element={<WordGroup />} />
          <Route path="/phrase" element={<Phrases />} />
          <Route path="/words" element={<Words />} />
          <Route path="/contact" element={<Contact />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
