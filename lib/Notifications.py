#! /usr/bin/python

#Functions for handling notifactions
import sendemail as E
import config
import socket, time
from Adafruit_CharLCDPlate import Adafruit_CharLCDPlate


class Notifications:

    lcd         = Adafruit_CharLCDPlate()
    sub_base    = "Alert from "
    hostname    = socket.gethostname()
    lastTimeN   = time.time()
    now         = time.time()
    slice       = now - lastTimeN
    first       = 1

    def __init__(self):
        lastTimeN = time.time()

    #Select alert and control email send rate
    def sendAlert(self, alert):
        if (config.ALERT_ENABLED == 1):
            self.now = time.time()
            self.since = self.now - self.lastTimeN
            if (self.since > config.ALERT_TIME or self.since < 0.0 or self.first == 1):
                self.lastTimeN = self.now
                if (self.first == 1): self.first = 0
                self.lcd.backlight(self.lcd.RED)
                if (alert == 0): self.S_HashAlert()
                if (alert == 1): self.S_MinerAlert()
                if (alert == 3): self.S_TempAlert()

    #Send Hash Alert
    def S_HashAlert(self):
        subject = self.sub_base + self.hostname
        text = "Alert hash rate below threshold on miner " + self.hostname
        html = "Alert hash rate below threshold on miner <B>" + self.hostname + "</B>"
        E.send_email(config.GMAIL_USER, config.GMAIL_PASS, config.SMTP_SERVER, config.SMTP_PORT, config.RECIPIENT, subject, text, html)
        
        


    #Send Miner Alert
    def S_MinerAlert(self):
        subject = self.sub_base + self.hostname
        text = "Alert miner not running " + self.hostname
        html = "Alert miner not running <B>" + self.hostname + "</B>"
        E.send_email(config.GMAIL_USER, config.GMAIL_PASS, config.SMTP_SERVER, config.SMTP_PORT, config.RECIPIENT, subject, text, html)



    #Send Miner Temp Alert
    def S_TempAlert(self):
        subject = self.sub_base + self.hostname
        text = "Alert miner temp above threshold on " + self.hostname
        html = "Alert miner temp above threshold on <B>" + self.hostname + "</B>"
        E.send_email(config.GMAIL_USER, config.GMAIL_PASS, config.SMTP_SERVER, config.SMTP_PORT, config.RECIPIENT, subject, text, html)
