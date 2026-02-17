import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: String,
    email: { type: String, unique: true },
    password: { type: String, default: null },
    provider: { type: String, default: "local" },

    gamesPlayed: { type: Number, default: 0 },
    win: { type: Number, default: 0 },
    loss: { type: Number, default: 0 },
    draw: { type: Number, default: 0 },
    lastLogin: { type: Date, default: null },
  },
  { timestamps: true },
);
export default mongoose.model("User", userSchema);
