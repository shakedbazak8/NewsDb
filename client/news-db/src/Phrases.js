import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Phrases.css'; // Ensure you have a CSS file for styling

const Phrases = () => {
    const [phrase, setPhrase] = useState(""); // State for the phrase
    const [definition, setDefinition] = useState(""); // State for the definition
    const [phrasesList, setPhrasesList] = useState([]); // List to store the phrases
    const [isLoading, setIsLoading] = useState(false); // Loading state
    const [error, setError] = useState(""); // Error state for handling fetch errors

    // Fetch phrases from API when the component mounts or after adding a new phrase
    const fetchPhrases = async () => {
        setIsLoading(true);
        try {
            const response = await axios.get('http://localhost:8003/phrases'); // Update with your API endpoint
            setPhrasesList(response.data); // Assuming the response is an array of phrases
        } catch (err) {
            setError("Failed to load phrases.");
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    // Load phrases when the component mounts
    useEffect(() => {
        fetchPhrases();
    }, []); // Empty dependency array means this effect runs only once when the component mounts

    // Handle input changes for the phrase
    const handlePhraseChange = (e) => {
        setPhrase(e.target.value);
    };

    // Handle input changes for the definition
    const handleDefinitionChange = (e) => {
        setDefinition(e.target.value);
    };

    // Handle adding the phrase and its definition
    const handleAddPhrase = async () => {
        if (phrase && definition) {
            try {
                // Optionally, you can send a POST request to save the phrase to the backend
                await axios.post('http://localhost:8003/phrases', { phrase, definition }); // Update with your API endpoint

                // Fetch the updated phrases list after successfully adding a new phrase
                fetchPhrases();

                // Reset inputs
                setPhrase("");
                setDefinition("");
            } catch (err) {
                setError("Failed to add phrase.");
                console.error(err);
            }
        } else {
            alert("Please provide both a phrase and its definition.");
        }
    };

    return (
        <div className="phrases-container">
            <h2>Phrases</h2>

            {/* Loading indicator */}
            {isLoading && <p>Loading phrases...</p>}
            {error && <p className="error">{error}</p>}

            {/* Form to create a phrase */}
            <form onSubmit={(e) => e.preventDefault()}>
                <div className="form-group">
                    <label htmlFor="phrase">Phrase</label>
                    <input
                        type="text"
                        id="phrase"
                        value={phrase}
                        onChange={handlePhraseChange}
                        placeholder="Enter phrase"
                    />
                </div>

                <div className="form-group">
                    <label htmlFor="definition">Definition</label>
                    <input
                        type="text"
                        id="definition"
                        value={definition}
                        onChange={handleDefinitionChange}
                        placeholder="Enter definition"
                    />
                </div>

                <button type="button" className="submit-btn" onClick={handleAddPhrase}>
                    Add Phrase
                </button>
            </form>

            {/* List of current phrases */}
            <h3>Current Phrases</h3>
            {phrasesList.length > 0 ? (
                <ul className="phrases-list">
                    {phrasesList.map((item, index) => (
                        <li key={index} className="phrase-item">
                            <strong>{item.phrase}</strong>
                            <p>{item.definition}</p>
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No phrases available.</p>
            )}
        </div>
    );
};

export default Phrases;
