import mongoose from "mongoose";

const connectDB = async () => {
  if (!process.env.MONGODB_URI) {
    throw new Error("MONGODB_URI not found in env");
  }

  await mongoose.connect(process.env.MONGODB_URI);
  console.log("MongoDB connected");
};

export default connectDB;
