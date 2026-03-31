import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os

def send_otp_email(receiver_email: str, otp_code: str):
    sender_email = "jeevankiran14341@gmail.com"
    # App password from screenshot: silr ihnj mpxe gjiz
    # We strip spaces just in case
    password = "silrihnjmpxegjiz"
    
    message = MIMEMultipart("alternative")
    message["Subject"] = "ChildCare AI - Password Reset OTP"
    message["From"] = sender_email
    message["To"] = receiver_email

    text = f"Your OTP for password reset is: {otp_code}\nThis code expires in 10 minutes."
    html = f"""
    <html>
      <body>
        <h2>Password Reset Request</h2>
        <p>You requested to reset your password for ChildCare AI.</p>
        <p>Your 6-digit verification code is:</p>
        <h1 style="color: #4A90E2; letter-spacing: 5px;">{otp_code}</h1>
        <p>This code will expire in 10 minutes.</p>
        <p>If you did not request this, please ignore this email.</p>
      </body>
    </html>
    """

    part1 = MIMEText(text, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender_email, password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def send_approval_email(receiver_email: str, name: str):
    sender_email = "jeevankiran14341@gmail.com"
    password = "silrihnjmpxegjiz"
    
    message = MIMEMultipart("alternative")
    message["Subject"] = "Welcome to ChildCare AI - Account Approved!"
    message["From"] = sender_email
    message["To"] = receiver_email

    text = f"Hi {name},\n\nGreat news! Your account on ChildCare AI has been approved by our admin.\nYou can now log in and access all platform features.\n\nBest regards,\nThe ChildCare AI Team"
    html = f"""
    <html>
      <body style="font-family: Arial, sans-serif; color: #333;">
        <h2 style="color: #4CAF50;">Congratulations!</h2>
        <p>Hi <strong>{name}</strong>,</p>
        <p>Great news! Your account on <strong>ChildCare AI</strong> has been approved by our administrator.</p>
        <p>You can now log in using your registered email and password to access all platform features.</p>
        <div style="margin: 30px 0;">
            <a href="#" style="background-color: #4CAF50; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; font-weight: bold;">Login to App</a>
        </div>
        <p>If you have any questions, feel free to reply to this email.</p>
        <p>Best regards,<br>The ChildCare AI Team</p>
      </body>
    </html>
    """

    part1 = MIMEText(text, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender_email, password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        return True
    except Exception as e:
        print(f"Error sending approval email: {e}")
        return False

def send_booking_confirmation_email(receiver_email: str, provider_name: str, booking_date: str):
    sender_email = "jeevankiran14341@gmail.com"
    password = "silrihnjmpxegjiz"
    
    message = MIMEMultipart("alternative")
    message["Subject"] = "Booking Confirmed - ChildCare AI"
    message["From"] = sender_email
    message["To"] = receiver_email

    text = f"Your booking with {provider_name} for {booking_date} has been confirmed.\n\nYou can now start a conversation with the provider in the Messages tab."
    html = f"""
    <html>
      <body style="font-family: Arial, sans-serif; color: #333;">
        <h2 style="color: #2196F3;">Booking Confirmed!</h2>
        <p>The provider <strong>{provider_name}</strong> has confirmed your booking for <strong>{booking_date}</strong>.</p>
        <p>You can now start a real-time conversation with them via the <strong>Messages</strong> tab in the app.</p>
        <p>Thank you for using ChildCare AI!</p>
      </body>
    </html>
    """

    part1 = MIMEText(text, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(sender_email, password)
            server.sendmail(sender_email, receiver_email, message.as_string())
        return True
    except Exception as e:
        print(f"Error sending booking confirmation email: {e}")
        return False
