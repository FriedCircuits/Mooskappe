#! /usr/bin/python
# -*- coding: utf-8 -*-

#Email module for PiMiner
#William Garrido
#Create 07-29-2014
#Based on code from my other python work on
#http://github.com/friedcircuits
#Used example and such for the email function, can’t remember from where
#License
#CC-BY-SA


__version__ = "0.01"

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def send_email(GMAIL_USER, GMAIL_PASS, SMTP_SERVER, SMTP_PORT, RECIPIENT, subject, text, html):
    smtpserver = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    smtpserver.ehlo()
    smtpserver.starttls()
    smtpserver.ehlo
    smtpserver.login(GMAIL_USER, GMAIL_PASS)
    
    # Create message container - the correct MIME type is multipart/alternative.
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = GMAIL_USER
    msg['To'] = ', '.join( RECIPIENT )
    
    #Old code below
    #header = 'To:' + recipient + '\n' + 'From: ' + GMAIL_USER
    #header = header + '\n' + 'Subject:' + subject + '\n'
    #msg = header + '\n' + text + ' \n\n'
    
    html = """\
    <html>
       <head></head>
         <body>
           <p>"""+html+"""\
	  </p>
       </body>
    </html>
    """ 
    
    # Record the MIME types of both parts - text/plain and text/html.
    part1 = MIMEText(text, 'plain')
    part2 = MIMEText(html, 'html')

    # Attach parts into message container.
    # According to RFC 2046, the last part of a multipart message, in this case
    # the HTML message, is best and preferred.
    msg.attach(part1)
    msg.attach(part2)
    
    smtpserver.sendmail(GMAIL_USER, RECIPIENT, msg.as_string())
    smtpserver.close()
