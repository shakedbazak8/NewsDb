// DownloadDatabase.js
import React from 'react';
import axios from "axios";

const DownloadDatabase = () => {
    const handleDownload = async () => {
        try {
            // Axios GET request with responseType set to 'blob'
            const response = await axios.get("http://localhost:8003/export-db", {
                responseType: "blob", // Specify that the response will be a Blob
            });

            // Create a link element to simulate a file download
            const link = document.createElement("a");

            // Create an object URL for the Blob and set it as the href of the link
            link.href = URL.createObjectURL(response.data);
            link.download = "backup.xml"; // Set the filename here

            // Append the link to the document body, trigger a click to start the download, and remove the link
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

        } catch (error) {
            console.error("Error downloading file:", error);
        }
    };

    return (
        <div className="download-container">
            <h3>Download Database</h3>
            <button onClick={handleDownload}>
                Download Database
            </button>
        </div>
    );
};

export default DownloadDatabase;
