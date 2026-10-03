import nodemailer from "nodemailer";

const SENDER_NAME = "BingoGame";
const SENDER_EMAIL = "bingogame@donotreply";

let transporter = null;

const getTransporter = () => {
  if (transporter) return transporter;

  const clean = (v = "") =>
    v
      .trim()
      .replace(/^["']|["']$/g, "")
      .trim();
  const user = clean(process.env.EMAIL_USER);
  const pass = clean(process.env.EMAIL_PASSWORD).replace(/\s+/g, "");

  if (!user || !pass) {
    throw new Error("EMAIL_USER / EMAIL_PASSWORD not found in env");
  }

  transporter = nodemailer.createTransport({
    service: "gmail",
    auth: { user, pass },
  });

  return transporter;
};

const escapeHtml = (v = "") =>
  String(v)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");

const sendMail = async ({ to, subject, text, html }) => {
  const transport = getTransporter();

  await transport.sendMail({
    from: `"${SENDER_NAME}" <${SENDER_EMAIL}>`,
    to,
    subject,
    text,
    html,
    envelope: { from: transport.options.auth.user, to },
  });
};

export const sendOtpEmail = async ({ to, name, otp, expiresInMinutes }) => {
  const html = `
    <div style="font-family:Arial,sans-serif;max-width:460px;margin:auto;padding:24px;border:1px solid #e5e7eb;border-radius:12px;">
      <h2 style="margin:0 0 12px;color:#111827;">Reset your BingoGame password</h2>
      <p style="color:#374151;">Hi ${escapeHtml(name) || "Player"},</p>
      <p style="color:#374151;">Use this OTP to reset your password:</p>
      <div style="font-size:32px;letter-spacing:8px;font-weight:700;text-align:center;background:#fef3c7;color:#92400e;padding:14px;border-radius:10px;">
        ${otp}
      </div>
      <p style="color:#6b7280;font-size:13px;margin-top:16px;">
        This OTP is valid for ${expiresInMinutes} minutes. If you didn't request this, you can safely ignore this email.
      </p>
    </div>
  `;

  await sendMail({
    to,
    subject: "Your BingoGame password reset OTP",
    text: `Your BingoGame OTP is ${otp}. It is valid for ${expiresInMinutes} minutes.`,
    html,
  });
};

export const sendWelcomeEmail = async ({ to, name }) => {
  const safeName = escapeHtml(name) || "Player";

  const html = `
    <div style="font-family:Arial,sans-serif;max-width:460px;margin:auto;padding:24px;border:1px solid #e5e7eb;border-radius:12px;">
      <h2 style="margin:0 0 12px;color:#111827;">Welcome to BingoGame 🎉</h2>
      <p style="color:#374151;">Hi ${safeName},</p>
      <p style="color:#374151;">
        Your account has been created successfully. You can now create a room,
        invite your friends and play Bingo with them, or play against the bot.
      </p>
      <p style="color:#374151;">Have fun and good luck!</p>
      <p style="color:#6b7280;font-size:13px;margin-top:16px;">
        If you didn't create this account, you can ignore this email.
      </p>
    </div>
  `;

  await sendMail({
    to,
    subject: "Welcome to BingoGame!",
    text: `Hi ${name || "Player"}, your BingoGame account has been created successfully. Have fun!`,
    html,
  });
};
