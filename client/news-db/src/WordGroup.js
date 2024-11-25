import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './WordGroup.css'; // Ensure you have a CSS file for styling

const WordGroup = () => {
    const [name, setName] = useState(""); // State for the group name
    const [words, setWords] = useState([]); // State to store words (chips) for the current group
    const [wordGroups, setWordGroups] = useState([]); // State to store created word groups
    const [availableWords, setAvailableWords] = useState([]); // State to store fetched words from API
    const [isLoading, setIsLoading] = useState(false); // Loading state for fetching words
    const [error, setError] = useState(""); // Error state for any issues fetching words

    const fetchWords = async () => {
        setIsLoading(true);
        try {
            // Replace with your actual API endpoint
            const response = await axios.get('http://localhost:8003/groups');
            // Assuming the response format is { name: string, words: array[string] }
            const groups = response.data; // The response should be an array of groups
            setWordGroups(groups || []); // Ensure it's an array, even if empty
        } catch (error) {
            setError('Failed to fetch words from the API.');
        } finally {
            setIsLoading(false);
        }
    };

    // Fetch words from API on component mount
    useEffect(() => {
        fetchWords();
    }, []);

    // Handle input changes for the group name
    const handleGroupNameChange = (e) => {
        setName(e.target.value);
    };

    // Handle adding a word (chip)
    const handleAddWord = (word) => {
        if (word && !words.includes(word)) {
            setWords([...words, word]);
        }
    };

    // Handle removing a word (chip)
    const handleRemoveWord = (wordToRemove) => {
        setWords(words.filter((word) => word !== wordToRemove));
    };

    // Handle form submission to create a word group
    const handleCreateWordGroup = (e) => {
        e.preventDefault();
        if (name && words.length > 0) {
            const newGroup = { name, words };
            const resp = axios.post("http://localhost:8003/groups", {"name": name, "words": words});
            fetchWords();
            setName(""); // Reset group name
            setWords([]); // Reset word list for new group
        } else {
            alert("Please provide a name and add some words to the group.");
        }
    };

    // Prevent form submission on Enter key press in word input
    const handleWordKeyDown = (e) => {
        if (e.key === "Enter" && e.target.value.trim()) {
            e.preventDefault(); // Prevent form submission
            handleAddWord(e.target.value.trim()); // Add word to the list
            e.target.value = ""; // Clear input after adding
        }
    };

    return (
        <div className="word-group-container">
            <h2>Word Groups</h2>

            {/* Form to create a word group */}
            <form onSubmit={handleCreateWordGroup}>
                <div className="form-group">
                    <label htmlFor="groupName">Word Group Name</label>
                    <input
                        type="text"
                        id="groupName"
                        value={name}
                        onChange={handleGroupNameChange}
                        placeholder="Enter word group name"
                    />
                </div>

                {/* Words input */}
                <div className="form-group">
                    <label htmlFor="words">Words (Chips)</label>
                    <input
                        type="text"
                        id="words"
                        onKeyDown={handleWordKeyDown} // Use this custom handler
                        placeholder="Add words (press Enter)"
                    />
                    {/* Display added chips */}
                    <div className="chips">
                        {words.map((word, index) => (
                            <span key={index} className="chip">
                                {word}{" "}
                                <span className="remove-chip" onClick={() => handleRemoveWord(word)}>
                                    x
                                </span>
                            </span>
                        ))}
                    </div>

                    {/* Dropdown for available words fetched from the API */}
                    <div className="available-words">
                        {isLoading ? (
                            <p>Loading words...</p>
                        ) : error ? (
                            <p>{error}</p>
                        ) : (
                            <ul>
                                {/* Ensure availableWords is an array before calling .map() */}
                                {Array.isArray(availableWords) && availableWords.length > 0 ? (
                                    availableWords.map((word, index) => (
                                        <li key={index} onClick={() => handleAddWord(word)}>
                                            {word}
                                        </li>
                                    ))
                                ) : (
                                    <li>No words available.</li>
                                )}
                            </ul>
                        )}
                    </div>
                </div>

                <button type="submit" className="submit-btn">
                    Create Word Group
                </button>
            </form>

            {/* Display Groups as Cards */}
            <div className="word-group-cards">
                {wordGroups.length > 0 ? (
                    wordGroups.map((group, index) => (
                        <div key={index} className="word-group-card">
                            <div className="card-header">
                                <h4>{group.name}</h4>
                            </div>
                            <div className="card-body">
                                <div className="chips">
                                    {group.words.map((word, idx) => (
                                        <span key={idx} className="chip">{word}</span>
                                    ))}
                                </div>
                            </div>
                        </div>
                    ))
                ) : (
                    <p>No word groups created yet.</p>
                )}
            </div>
        </div>
    );
};

export default WordGroup;
