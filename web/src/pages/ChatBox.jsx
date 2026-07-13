import React, { useEffect, useState, useRef } from "react";
import { socket } from "../services/socket";
import "../styles/ChatBox.css";

// Simple chat box for the game screen.
// Props:
// - roomId: the room the two players are playing in
// - myUserId: my own user id
// - myName: my own name (shown next to my messages)
const ChatBox = ({ roomId, myUserId, myName }) => {
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState("");
  const [isOpen, setIsOpen] = useState(true);
  const [unreadCount, setUnreadCount] = useState(0);
  const chatEndRef = useRef(null);

  // Listen for incoming messages from the server
  useEffect(() => {
    const handleReceive = (data) => {
      setMessages((prev) => [...prev, data]);

      // if the chat panel is collapsed, count the new message as unread
      setIsOpen((currentlyOpen) => {
        if (!currentlyOpen) {
          setUnreadCount((count) => count + 1);
        }
        return currentlyOpen;
      });
    };

    socket.on("chat:receive", handleReceive);

    // clean up the listener when component is removed
    return () => {
      socket.off("chat:receive", handleReceive);
    };
  }, []);

  // Auto scroll to the latest message
  useEffect(() => {
    if (chatEndRef.current) {
      chatEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages, isOpen]);

  const sendMessage = () => {
    // don't send empty messages
    if (text.trim() === "") return;

    socket.emit("chat:send", {
      roomId,
      message: text.trim(),
      senderId: myUserId,
      senderName: myName || "Player",
    });

    setText(""); // clear the input box
  };

  const handleKeyPress = (e) => {
    if (e.key === "Enter") {
      sendMessage();
    }
  };

  const toggleChat = () => {
    setIsOpen((prev) => !prev);
    if (!isOpen) {
      // opening the chat, so clear the unread badge
      setUnreadCount(0);
    }
  };

  return (
    <div className="chatbox-container">
      <button className="chatbox-header" onClick={toggleChat}>
        <span className="chatbox-header-left">
          <span className="chatbox-live-dot"></span>
          Match Chat
        </span>

        <span className="chatbox-header-right">
          {!isOpen && unreadCount > 0 && (
            <span className="chatbox-unread-badge">{unreadCount}</span>
          )}
          <span className={`chatbox-arrow ${isOpen ? "open" : ""}`}>▾</span>
        </span>
      </button>

      {isOpen && (
        <>
          <div className="chatbox-messages">
            {messages.length === 0 && (
              <div className="chatbox-empty">
                Say hi to your opponent 👋
              </div>
            )}

            {messages.map((msg, index) => (
              <div
                key={index}
                className={
                  msg.senderId === myUserId
                    ? "chatbox-message my-message"
                    : "chatbox-message other-message"
                }
              >
                <span className="chatbox-sender">{msg.senderName}</span>
                <span className="chatbox-text">{msg.message}</span>
                <span className="chatbox-time">{msg.time}</span>
              </div>
            ))}
            {/* empty div used just to auto-scroll to the bottom */}
            <div ref={chatEndRef}></div>
          </div>

          <div className="chatbox-input-area">
            <input
              type="text"
              value={text}
              placeholder="Type a message..."
              maxLength={200}
              onChange={(e) => setText(e.target.value)}
              onKeyPress={handleKeyPress}
              className="chatbox-input"
            />
            <button
              onClick={sendMessage}
              className="chatbox-send-btn"
              disabled={text.trim() === ""}
              aria-label="Send message"
            >
              ➤
            </button>
          </div>
        </>
      )}
    </div>
  );
};

export default ChatBox;
