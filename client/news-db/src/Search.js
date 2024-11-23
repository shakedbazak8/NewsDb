import React, { useState } from 'react';
import './Search.css'; // Make sure the CSS file is imported

const Search = ({ articles = [] }) => {
    // State for form fields
    const [title, setTitle] = useState("");
    const [page, setPage] = useState("");
    const [author, setAuthor] = useState("");
    const [publishDate, setPublishDate] = useState("");
    const [subject, setSubject] = useState("");
    const [paperName, setPaperName] = useState("");
    const [words, setWords] = useState([]); // State for storing chips (keywords)

    const [filteredArticles, setFilteredArticles] = useState(articles); // Filtered articles state

    // Handle form input change
    const handleInputChange = (e) => {
        const { id, value } = e.target;
        switch(id) {
            case 'title':
                setTitle(value);
                break;
            case 'page':
                setPage(value);
                break;
            case 'author':
                setAuthor(value);
                break;
            case 'publishDate':
                setPublishDate(value);
                break;
            case 'subject':
                setSubject(value);
                break;
            case 'paperName':
                setPaperName(value);
                break;
            default:
                break;
        }
    };

    // Handle adding/removing words (chips)
    const handleAddWord = (word) => {
        if (word && !words.includes(word)) {
            setWords([...words, word]);
        }
    };

    const handleRemoveWord = (wordToRemove) => {
        setWords(words.filter(word => word !== wordToRemove));
    };

    // Handle search/filter
    const handleSearch = (event) => {
        event.preventDefault();

        // Apply filters based on the form data
        const filtered = articles.filter(article => {
            return (
                (title === "" || article.title.toLowerCase().includes(title.toLowerCase())) &&
                (page === "" || article.page.toLowerCase().includes(page.toLowerCase())) &&
                (author === "" || article.author.toLowerCase().includes(author.toLowerCase())) &&
                (publishDate === "" || article.publishDate === publishDate) &&
                (subject === "" || article.subject.toLowerCase().includes(subject.toLowerCase())) &&
                (paperName === "" || article.paperName.toLowerCase().includes(paperName.toLowerCase())) &&
                (words.length === 0 || words.every(word => article.keywords.includes(word))) // Filter based on keywords (chips)
            );
        });

        // Set the filtered articles
        setFilteredArticles(filtered);
    };

    return (
        <div className="search-container">
            <h2>Search Articles</h2>

            {/* Search form */}
            <form onSubmit={handleSearch}>
                {/* Title input */}
                <div className="form-group">
                    <label htmlFor="title">Title</label>
                    <input
                        type="text"
                        id="title"
                        value={title}
                        onChange={handleInputChange}
                        placeholder="Search by title"
                    />
                </div>

                {/* Page input */}
                <div className="form-group">
                    <label htmlFor="page">Page</label>
                    <input
                        type="text"
                        id="page"
                        value={page}
                        onChange={handleInputChange}
                        placeholder="Search by page"
                    />
                </div>

                {/* Author input */}
                <div className="form-group">
                    <label htmlFor="author">Author</label>
                    <input
                        type="text"
                        id="author"
                        value={author}
                        onChange={handleInputChange}
                        placeholder="Search by author"
                    />
                </div>

                {/* Publish Date input */}
                <div className="form-group">
                    <label htmlFor="publishDate">Publish Date</label>
                    <input
                        type="date"
                        id="publishDate"
                        value={publishDate}
                        onChange={handleInputChange}
                        placeholder="Search by publish date"
                    />
                </div>

                {/* Subject input */}
                <div className="form-group">
                    <label htmlFor="subject">Subject</label>
                    <input
                        type="text"
                        id="subject"
                        value={subject}
                        onChange={handleInputChange}
                        placeholder="Search by subject"
                    />
                </div>

                {/* Paper Name input */}
                <div className="form-group">
                    <label htmlFor="paperName">Paper Name</label>
                    <input
                        type="text"
                        id="paperName"
                        value={paperName}
                        onChange={handleInputChange}
                        placeholder="Search by paper name"
                    />
                </div>

                {/* Words (Chips) input */}
                <div className="form-group">
                    <label htmlFor="words">Words</label>
                    <input
                        type="text"
                        id="words"
                        onKeyDown={(e) => {
                            if (e.key === "Enter" && e.target.value.trim()) {
                                handleAddWord(e.target.value.trim());
                                e.target.value = ""; // Clear input after adding
                            }
                        }}
                        placeholder="Add keywords (press Enter)"
                    />
                    {/* Display added chips */}
                    <div className="chips">
                        {words.map((word, index) => (
                            <span key={index} className="chip">
                {word}
                                <span className="remove-chip" onClick={() => handleRemoveWord(word)}>x</span>
              </span>
                        ))}
                    </div>
                </div>

                {/* Submit button */}
                <button type="submit" className="submit-btn">Search</button>
            </form>

            {/* Display filtered results */}
            {filteredArticles.length > 0 ? (
                <div className="article-list">
                    {filteredArticles.map((article, index) => (
                        <div key={index} className="article-item">
                            <h3>{article.title}</h3>
                            <p>By {article.author}</p>
                            <p>Published on {article.publishDate}</p>
                            <p>Subject: {article.subject}</p>
                            <p>Paper Name: {article.paperName}</p>
                            <p>Keywords: {article.keywords.join(", ")}</p>
                        </div>
                    ))}
                </div>
            ) : (
                <p>No articles found matching your search criteria.</p>
            )}
        </div>
    );
};

export default Search;
