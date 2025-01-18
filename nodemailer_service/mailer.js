const nodemailer = require('nodemailer');

// Retrieve arguments from the command line
const recipientEmail = process.argv[2];
const emailSubject = process.argv[3];
const emailBody = process.argv[4];

// Set up the transporter
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // true for port 465, false for 587
  auth: {
    user: process.env.SMTP_USER, // Your email
    pass: process.env.SMTP_PASSWORD // Your password or App Password
  }
});

// Send the email
transporter.sendMail({
  from: process.env.SMTP_USER, // Sender address
  to: recipientEmail, // Recipient address
  subject: emailSubject, // Subject line
  text: emailBody // Plain text body
}, (error, info) => {
  if (error) {
    console.error("Error sending email:", error);
    process.exit(1);
  } else {
    console.log("Email sent successfully:", info.messageId);
    process.exit(0);
  }
});
