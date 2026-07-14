import React, { useEffect, useState } from "react";
import "../styles/Result.css";

const Result = ({ winner, isDraw, onPlayAgain }) => {
  const [countdown, setCountdown] = useState(7);
  const [copyStatus, setCopyStatus] = useState("");

  const websiteUrl = "https://bingogame-web-t73z.vercel.app/";
  const isWin = winner === "You";

  useEffect(() => {
    const timer = setTimeout(() => {
      onPlayAgain();
    }, 7000);

    const interval = setInterval(() => {
      setCountdown((prev) => prev - 1);
    }, 1000);

    return () => {
      clearTimeout(timer);
      clearInterval(interval);
    };
  }, [onPlayAgain]);

  const copyWebsiteLink = async () => {
    if (!websiteUrl) return;

    try {
      await navigator.clipboard.writeText(websiteUrl);
      setCopyStatus("Link copied");
    } catch (error) {
      setCopyStatus("Copy failed");
    }

    setTimeout(() => setCopyStatus(""), 1800);
  };

  return (
    <div className="result-container">
      <div className="result-card">
        <h2 className="result-title">Game Result</h2>

        {!isDraw ? (
          <>
            <div
              className={`result-status ${isWin ? "win-text" : "lose-text"}`}
            >
              {isWin ? "🏆 You Win" : "😞 You Lose"}
            </div>
            <p className="result-winner-name">{winner}</p>
            <p className="result-sub">BINGO completed 🎉</p>
          </>
        ) : (
          <>
            <div className="draw-text">🤝 Draw</div>
            <p className="result-sub">Both players completed BINGO</p>
          </>
        )}

        <button className="play-again-btn" onClick={onPlayAgain}>
          Play Again
        </button>

        <div className="share-wrap">
          <p className="share-title">Share this website with more friends</p>
          <div className="share-link-row">
            <a
              href={websiteUrl}
              target="_blank"
              rel="noreferrer"
              className="share-link"
            >
              {websiteUrl}
            </a>
            <button
              type="button"
              onClick={copyWebsiteLink}
              className="copy-link-btn"
              title="Copy website link"
              aria-label="Copy website link"
            >
              <svg
                viewBox="0 0 24 24"
                width="18"
                height="18"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
              </svg>
            </button>
          </div>
          {copyStatus && <p className="copy-status">{copyStatus}</p>}
        </div>

        <div className="auto-text">Auto restarting in {countdown}s...</div>
      </div>
    </div>
  );
};

export default Result;
