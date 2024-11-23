import React, { useState } from 'react';
import './WordGroup.css'; // Ensure you have a CSS file for styling

const WordGroup = () => {
    const [groupName, setGroupName] = useState(""); // State for the group name
    const [words, setWords] = useState([]); // State to store words (chips)
    const [wordGroups, setWordGroups] = useState([]); // State to store created word groups

    // Handle input changes for the group name
    const handleGroupNameChange = (e) => {
        setGroupName(e.target.value);
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
        if (groupName && words.length > 0) {
            const newGroup = { groupName, words };
            setWordGroups([...wordGroups, newGroup]); // Add the new group to the list
            setGroupName(""); // Reset group name
            setWords([]); // Reset word list
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
                        value={groupName}
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
                </div>

                <button type="submit" className="submit-btn">
                    Create Word Group
                </button>
            </form>

            {/* List of current word groups */}
            <h3>Current Word Groups</h3>
            {wordGroups.length > 0 ? (
                <ul className="word-group-list">
                    {wordGroups.map((group, index) => (
                        <li key={index} className="word-group-item">
                            <strong>{group.groupName}</strong>
                            <div className="chips">
                                {group.words.map((word, idx) => (
                                    <span key={idx} className="chip">{word}</span>
                                ))}
                            </div>
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No word groups created yet.</p>
            )}
        </div>
    );
};

export default WordGroup;
