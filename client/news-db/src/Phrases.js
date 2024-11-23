import React, { useState } from 'react';
import './Phrases.css'; // Ensure you have a CSS file for styling

const Phrases = () => {
    const [phrase, setPhrase] = useState(""); // State for the phrase
    const [definition, setDefinition] = useState(""); // State for the definition
    const [phrasesList, setPhrasesList] = useState([]); // List to store the phrases

    // Handle input changes for the phrase
    const handlePhraseChange = (e) => {
        setPhrase(e.target.value);
    };

    // Handle input changes for the definition
    const handleDefinitionChange = (e) => {
        setDefinition(e.target.value);
    };

    // Handle adding the phrase and its definition
    const handleAddPhrase = () => {
        if (phrase && definition) {
            const newPhrase = { phrase, definition };
            setPhrasesList([...phrasesList, newPhrase]); // Add the new phrase to the list
            setPhrase(""); // Reset phrase input
            setDefinition(""); // Reset definition input
        } else {
            alert("Please provide both a phrase and its definition.");
        }
    };

    // Handle form submission to create a phrase group
    const handleSubmit = (e) => {
        e.preventDefault();
        // This can be expanded to save the phrases to a backend or local storage if needed
    };

    return (
        <div className="phrases-container">
            <h2>Phrases</h2>

            {/* Form to create a phrase */}
            <form onSubmit={handleSubmit}>
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
                <p>No phrases created yet.</p>
            )}
        </div>
    );
};

export default Phrases;
