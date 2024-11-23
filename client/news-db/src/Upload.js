import React, { useState } from 'react';
import './Upload.css'; // Importing the style file

const Upload = () => {
    const [file, setFile] = useState(null);
    const [error, setError] = useState("");
    const [title, setTitle] = useState(""); // For the title field
    const [page, setPage] = useState(""); // For the description field
    const [author, setAuthor] = useState(""); // For the description field
    const [publishDate, setPublishDate] = useState(""); // For the description field
    const [subject, setSubject] = useState(""); // For the description field
    const [paperName, setPaperName] = useState(""); // For the description field

    // Handle file selection
    const handleFileChange = (event) => {
        const selectedFile = event.target.files[0];

        if (selectedFile) {
            // Check file size and type (optional validation)
            if (selectedFile.size > 5000000) { // Limit to 5MB
                setError("File size should not exceed 5MB.");
                setFile(null); // Clear previous file
                return;
            } else if (!selectedFile.name.endsWith(".txt")) { // Only allow .txt files
                setError("Please upload a .txt file.");
                setFile(null); // Clear previous file
                return;
            } else {
                // Reset error message
                setError("");
                setFile(selectedFile);
            }
        }
    };

    // Render file information if file is selected
    const renderFileAttributes = () => {
        if (file) {
            return (
                <div className="file-attributes">
                    <p><strong>File Name:</strong> {file.name}</p>
                    <p><strong>File Size:</strong> {(file.size / 1024 / 1024).toFixed(2)} MB</p>
                    <p><strong>File Type:</strong> {file.type}</p>
                </div>
            );
        }
        return null;
    };

    // Handle form submission (optional)
    const handleSubmit = (event) => {
        event.preventDefault();
        if (!file) {
            setError("Please upload a file before submitting.");
            return;
        }
        // You can replace this with your API request to upload the file and metadata
    };

    return (
        <div className="file-upload-container">
            <h2>Upload Your File</h2>
            <form onSubmit={handleSubmit}>
                {/* Title input */}
                <div className="form-group">
                    <label htmlFor="title">Title</label>
                    <input
                        type="text"
                        id="title"
                        placeholder="Enter title"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                    />
                </div>

                {/* Page input */}
                <div className="form-group">
                    <label htmlFor="page">Page</label>
                    <input
                        type = "text"
                        id="page"
                        placeholder="Enter Page"
                        value={page}
                        onChange={(e) => setPage(e.target.value)}
                    />
                </div>

                {/* Author input */}
                <div className="form-group">
                    <label htmlFor="author">Author</label>
                    <input
                        type = "text"
                        id="author"
                        placeholder="Enter Author"
                        value={author}
                        onChange={(e) => setAuthor(e.target.value)}
                    />
                </div>

                {/* PublishDate input */}
                <div className="form-group">
                    <label htmlFor="publishDate">Publish Date</label>
                    <input
                        type = "date"
                        id="publishDate"
                        placeholder="Enter Publish Date"
                        value={publishDate}
                        onChange={(e) => setPublishDate(e.target.value)}
                    />
                </div>

                {/* Subject input */}
                <div className="form-group">
                    <label htmlFor="subject">Subject</label>
                    <input
                        type = "text"
                        id="subject"
                        placeholder="Enter Subject"
                        value={subject}
                        onChange={(e) => setSubject(e.target.value)}
                    />
                </div>

                {/* Paper Name input */}
                <div className="form-group">
                    <label htmlFor="paperName">Paper Name</label>
                    <input
                        type = "text"
                        id="paperName"
                        placeholder="Enter Paper Name"
                        value={paperName}
                        onChange={(e) => setPaperName(e.target.value)}
                    />
                </div>

                {/* File input */}
                <div className="form-group">
                    <label htmlFor="file">Select a file (.txt only)</label>
                    <input
                        type="file"
                        id="file"
                        onChange={handleFileChange}
                    />
                </div>

                {/* Error message */}
                {error && <p className="error-message">{error}</p>}

                {/* Display file attributes */}
                {renderFileAttributes()}

                {/* Submit button */}
                <button type="submit" className="submit-btn">Upload File</button>
            </form>
        </div>
    );
};

export default Upload;
