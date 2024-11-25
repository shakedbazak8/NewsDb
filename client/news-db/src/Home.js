// Home Component
import React from 'react';
import UploadDatabase from './UploadDatabase'; // Import UploadDatabase component
import DownloadDatabase from './DownloadDatabase'; // Import DownloadDatabase component

const Home = () => {
    return (
        <div className="page-content">
            <h2>Home Page</h2>
            <p>
                Welcome to the homepage of NewsDb! Here you'll find the latest updates on world events, tech, sports, and more.
            </p>

            <div className="db-actions">
                <UploadDatabase />
                <DownloadDatabase />
            </div>
        </div>
    );
};

export default Home;
