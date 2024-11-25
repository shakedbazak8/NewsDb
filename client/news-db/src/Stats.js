import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Stats.css'; // Ensure you have a CSS file for styling

const Stats = () => {
    const [statsData, setStatsData] = useState([]); // State to store the stats
    const [isLoading, setIsLoading] = useState(true); // Loading state
    const [error, setError] = useState(""); // Error state for API errors

    // Fetch stats from API when the component mounts
    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await axios.get('http://localhost:8003/stats');
                setStatsData(response.data); // Assuming the response is an array of stats
            } catch (err) {
                setError('Failed to load stats');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };

        fetchStats();
    }, []);

    // Function to get top 10 and remaining items
    const getTop10AndRemaining = (histogramData) => {
        if (!Array.isArray(histogramData)) return { top10: [], remainingCount: 0 };

        const sortedData = histogramData
            .sort((a, b) => b.count - a.count) // Sort by count in descending order
            .slice(0, 10); // Get the top 10

        const remainingCount = histogramData.length - sortedData.length;
        return { top10: sortedData, remainingCount };
    };

    return (
        <div className="stats-container">
            <h2>Statistics</h2>

            {isLoading ? (
                <p>Loading stats...</p>
            ) : error ? (
                <p>{error}</p>
            ) : (
                <div className="stats-cards">
                    {statsData.map((stat, index) => (
                        <div key={index} className="stat-card">
                            <h3>{stat.title}</h3>
                            <p><strong>Words:</strong> {stat.words}</p>
                            <p><strong>Groups:</strong> {stat.groups}</p>
                            <p><strong>Lines:</strong> {stat.lines}</p>
                            <p><strong>Paragraphs:</strong> {stat.paragraphs}</p>

                            {/* Groups Histogram */}
                            <div className="histogram">
                                <h4>Groups Histogram:</h4>
                                <ul>
                                    {getTop10AndRemaining(stat.groups_histogram).top10.map((item, idx) => (
                                        <li key={idx}>
                                            {item.term}: {item.cnt}
                                        </li>
                                    ))}
                                </ul>
                                {getTop10AndRemaining(stat.groups_histogram).remainingCount > 0 && (
                                    <p>And {getTop10AndRemaining(stat.groups_histogram).remainingCount} more...</p>
                                )}

                                {/* Words Histogram */}
                                <h4>Words Histogram:</h4>
                                <ul>
                                    {getTop10AndRemaining(stat.words_histogram).top10.map((item, idx) => (
                                        <li key={idx}>
                                            {item.term}: {item.cnt}
                                        </li>
                                    ))}
                                </ul>
                                {getTop10AndRemaining(stat.words_histogram).remainingCount > 0 && (
                                    <p>And {getTop10AndRemaining(stat.words_histogram).remainingCount} more...</p>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default Stats;
