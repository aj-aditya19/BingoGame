import express from "express";
import cors from "cors";
import testRoutes from "./routes/test.routes.js";
const app = express();

app.use(
  cors({
    origin: "*",
  }),
);
app.use(express.json());
app.use("/api/test", testRoutes);

export default app;