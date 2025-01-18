// mailer.js
const nodemailer = require('nodemailer');

// Set up the transporter
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com", // Change this to match the email provider
  port: 587,
  secure: false, // Use true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER, // Email login credentials from environment variables
    pass: process.env.SMTP_PASSWORD
  }
});

// Function to send email
async function sendEmail(to, subject, text) {
  try {
    const info = await transporter.sendMail({
      from: process.env.SMTP_USER, // Sender address
      to: to, // Receiver address
      subject: subject, // Subject line
      text: text // Plain text body
    });

    console.log("Message sent: %s", info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error("Error sending email:", error);
    return { success: false, error: error.message };
  }
}

// Expose the sendEmail function to other scripts
module.exports = sendEmail;

// To test the script locally, uncomment below lines and set up the environment variables:
sendEmail('tmakhija0@gmail.com', 'Test Subject', 'Test Message');
