import React from "react";
import "../styles/Landing.css";

const Landing = ({ onLogin, onRegister }) => {
  return (
    <div className="landing-container">
      <div className="landing-grid" />
      <div className="landing-glow landing-glow-left" />
      <div className="landing-glow landing-glow-right" />

      <main className="landing-shell">
        <section className="landing-copy landing-fade-up">
          <div className="landing-badge">Live multiplayer bingo</div>
          <h1 className="landing-title">
            Play bingo with friends in a bright, animated game room.
          </h1>
          <p className="landing-text">
            Create a room, join a match, and track every move in real time with
            smooth visuals, fast interactions, and a clean browser-first layout.
          </p>

          <div className="landing-actions">
            <button
              onClick={onLogin}
              className="landing-btn landing-btn-primary"
            >
              Login
            </button>
            <button
              onClick={onRegister}
              className="landing-btn landing-btn-secondary"
            >
              Create Account
            </button>
          </div>

          <div className="landing-stats">
            <div className="landing-stat-card">
              <span className="landing-stat-value">2</span>
              <span className="landing-stat-label">ways to start</span>
            </div>
            <div className="landing-stat-card">
              <span className="landing-stat-value">24/7</span>
              <span className="landing-stat-label">browser access</span>
            </div>
            <div className="landing-stat-card">
              <span className="landing-stat-value">Live</span>
              <span className="landing-stat-label">room updates</span>
            </div>
          </div>
        </section>

        <section className="landing-visual landing-float">
          <div className="landing-ribbon">
            Fast rooms. Smooth turns. No clutter.
          </div>

          <div className="landing-art-card">
            <div className="landing-art-header">
              <div>
                <span className="landing-art-kicker">Bingo Board</span>
                <h2 className="landing-art-title">Ready for the next round</h2>
              </div>
              <div className="landing-live-pill">
                <span className="landing-live-dot" />
                Live
              </div>
            </div>

            <svg
              viewBox="0 0 420 420"
              className="landing-board"
              role="img"
              aria-label="Stylized bingo board illustration"
            >
              <defs>
                <linearGradient
                  id="boardGradient"
                  x1="0%"
                  y1="0%"
                  x2="100%"
                  y2="100%"
                >
                  <stop offset="0%" stopColor="#fff7ed" />
                  <stop offset="100%" stopColor="#e0f2fe" />
                </linearGradient>
                <linearGradient
                  id="accentGradient"
                  x1="0%"
                  y1="0%"
                  x2="100%"
                  y2="100%"
                >
                  <stop offset="0%" stopColor="#fbbf24" />
                  <stop offset="100%" stopColor="#f97316" />
                </linearGradient>
              </defs>

              <rect
                x="20"
                y="20"
                width="380"
                height="380"
                rx="28"
                fill="url(#boardGradient)"
              />
              <rect
                x="40"
                y="40"
                width="340"
                height="56"
                rx="18"
                fill="#dbeafe"
                opacity="1"
              />
              <text
                x="63"
                y="76"
                fill="#1e3a8a"
                fontSize="28"
                fontWeight="700"
                letterSpacing="3"
              >
                BINGO
              </text>
              <circle cx="320" cy="68" r="16" fill="url(#accentGradient)" />
              <circle cx="348" cy="68" r="10" fill="#38bdf8" opacity="0.95" />

              {[0, 1, 2, 3, 4].map((row) =>
                [0, 1, 2, 3, 4].map((col) => {
                  const x = 40 + col * 68;
                  const y = 116 + row * 54;
                  const active = (row + col) % 3 === 0;

                  return (
                    <g key={`${row}-${col}`}>
                      <rect
                        x={x}
                        y={y}
                        width="56"
                        height="42"
                        rx="12"
                        fill={active ? "#fde68a" : "#ffffff"}
                        stroke={active ? "#f59e0b" : "#bfdbfe"}
                        strokeWidth="2"
                      />
                      {active && (
                        <circle
                          cx={x + 28}
                          cy={y + 21}
                          r="10"
                          fill="#ef4444"
                          opacity="0.9"
                        />
                      )}
                    </g>
                  );
                }),
              )}

              <rect
                x="64"
                y="352"
                width="292"
                height="16"
                rx="8"
                fill="#cbd5e1"
                opacity="0.9"
              />
              <rect
                x="64"
                y="352"
                width="186"
                height="16"
                rx="8"
                fill="url(#accentGradient)"
              />
            </svg>

            <div className="landing-float-card landing-float-top">
              <span className="landing-float-label">Room</span>
              <strong>8A2F</strong>
            </div>

            <div className="landing-float-card landing-float-bottom">
              <span className="landing-float-label">Players</span>
              <strong>2 connected</strong>
            </div>
          </div>

          <div className="landing-feature-row">
            <div className="landing-feature-card">
              <span className="landing-feature-icon">01</span>
              <h3>Pick a mode</h3>
              <p>Create a room or join one in a click.</p>
            </div>
            <div className="landing-feature-card">
              <span className="landing-feature-icon">02</span>
              <h3>Mark numbers live</h3>
              <p>Board updates stay synced for everyone.</p>
            </div>
            <div className="landing-feature-card">
              <span className="landing-feature-icon">03</span>
              <h3>Win together</h3>
              <p>Quick results, replay flow, and room reset.</p>
            </div>
          </div>
        </section>
      </main>
    </div>
  );
};

export default Landing;
