import smtplib
from email.mime.text import MIMEText

def send_email(to_email, subject, body):
    # Replace with your email and app password
    sender_email = "emailwithwaruna@gmail.com"
    sender_password = "hernwbfagviwujxt"

    # Create the email content
    msg = MIMEText(body)
    msg["Subject"] = subject
    msg["From"] = sender_email
    msg["To"] = to_email

    try:
        # Connect to Gmail SMTP server
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()  # Secure the connection
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, [to_email], msg.as_string())
        server.quit()
        print("Email sent successfully.")
    except Exception as e:
        print("Failed to send email:", str(e))


# Example usage
if __name__ == "__main__":
    send_email(
        to_email="malithaprabhashana@gmail.com",
        subject="Task Created",
        body="Your task 'Finish report' has been scheduled for 2025-08-07 at 15:00."
    )
