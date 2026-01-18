export default function socketConfig(io) {
  io.on("connection", (socket) => {
    console.log("Socket connected", socket.id);

    socket.emit("connected", {
      message: "Socket connected Successfully",
    });

    socket.on("disconnect", () => {
      console.log("Socket disconnected", socket.id);
    });
  });
}
