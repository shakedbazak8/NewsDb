import React, { useState } from 'react';
import axios from 'axios';

const UploadDatabase = () => {
    const [file, setFile] = useState(null);  // Holds the selected file
    const [isUploading, setIsUploading] = useState(false);  // Track upload state
    const [error, setError] = useState("");  // Track error message

    // Handle file selection
    const handleFileChange = (e) => {
        const uploadedFile = e.target.files[0];
        if (uploadedFile) {
            setFile(uploadedFile);
            setError(""); // Clear previous errors if a new file is selected
        }
    };

    // Handle file upload
    const handleUpload = async () => {
        if (!file) {
            setError("Please select a file to upload.");
            return;
        }

        if (!file.name.endsWith(".xml")) {
            setError("Please select a valid XML file.");
            return;
        }

        setIsUploading(true);
        const formData = new FormData();
        formData.append("file", file);

        try {
            // Replace with your actual API endpoint for uploading
            const response = await axios.post('http://localhost:8003/import-db', formData);

            if (response.status === 200) {
                alert("Database uploaded successfully!");
                setFile(null);  // Reset file state after successful upload
            } else {
                setError("Error uploading database.");
            }
        } catch (error) {
            console.error("Error uploading file:", error);
            setError("Error uploading database.");
        } finally {
            setIsUploading(false);
        }
    };

    return (
        <div className="upload-container">
            <h3>Upload Database</h3>
            <input
                type="file"
                onChange={handleFileChange}
                accept=".xml"  // Restrict file selection to XML files
                key={file ? file.name : ''}  // Reset input when file is updated
            />
            {error && <p className="error-message">{error}</p>}
            <button onClick={handleUpload} disabled={isUploading}>
                {isUploading ? 'Uploading...' : 'Upload Database'}
            </button>
        </div>
    );
};

export default UploadDatabase;
