#! /usr/bin/python
#Test Email with subfolder function
import lib.sendemail as E
import config



subject = "Test"
text = "test"
html = "<B>Test</B>"

E.send_email(config.GMAIL_USER, config.GMAIL_PASS, config.SMTP_SERVER, config.SMTP_PORT, config.RECIPIENT, subject, text, html)


