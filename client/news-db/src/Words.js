import React, { useState, useEffect } from 'react';
import './Words.css'; // Assuming you will have styling in this file

// Sample word data, this should ideally be fetched from an API or state.
const sampleWords = [
    { word: 'JavaScript', definition: 'A programming language used to create dynamic web content.' },
    { word: 'React', definition: 'A JavaScript library for building user interfaces.' },
    { word: 'Node.js', definition: 'A JavaScript runtime built on Chrome\'s V8 JavaScript engine.' },
    { word: 'Frontend', definition: 'The part of the website or web application that users interact with.' },
    { word: 'Backend', definition: 'The server-side part of the application that processes data and handles logic.' },
    { word: 'API', definition: 'Application Programming Interface, a set of rules for interacting with software components.' },
];

const Words = () => {
    const [search, setSearch] = useState(""); // Search input
    const [filteredWords, setFilteredWords] = useState(sampleWords); // List of words to show
    const [searchParams, setSearchParams] = useState({
        word: "",
        definition: "",
    });

    // Handle search input change
    const handleSearchChange = (e) => {
        setSearch(e.target.value);
    };

    // Filter words based on search parameters
    const filterWords = () => {
        const filtered = sampleWords.filter((item) => {
            const wordMatches = item.word.toLowerCase().includes(searchParams.word.toLowerCase());
            const definitionMatches = item.definition.toLowerCase().includes(searchParams.definition.toLowerCase());
            return wordMatches && definitionMatches;
        });
        setFilteredWords(filtered);
    };

    // Handle form submit to apply search filters
    const handleSubmit = (e) => {
        e.preventDefault();
        filterWords();
    };

    // Handle changes in search parameters
    const handleSearchParamChange = (e, param) => {
        setSearchParams({ ...searchParams, [param]: e.target.value });
    };

    useEffect(() => {
        filterWords();
    }, [searchParams]);

    return (
        <div className="words-container">
            <h2>Words List</h2>

            {/* Search Filters Form */}
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="word-search">Search by Word</label>
                    <input
                        type="text"
                        id="word-search"
                        value={searchParams.word}
                        onChange={(e) => handleSearchParamChange(e, 'word')}
                        placeholder="Enter word"
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="definition-search">Search by Definition</label>
                    <input
                        type="text"
                        id="definition-search"
                        value={searchParams.definition}
                        onChange={(e) => handleSearchParamChange(e, 'definition')}
                        placeholder="Enter definition"
                    />
                </div>

                <button type="submit" className="submit-btn">Search</button>
            </form>

            {/* List of words */}
            {filteredWords.length > 0 ? (
                <ul className="words-list">
                    {filteredWords.map((item, index) => (
                        <li key={index} className="word-item">
                            <strong>{item.word}</strong>
                            <p>{item.definition}</p>
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No words found.</p>
            )}
        </div>
    );
};

export default Words;
