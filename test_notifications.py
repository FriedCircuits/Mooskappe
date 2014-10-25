#! /usr/bin/python
#test notifications
from lib.Notifications import Notifications
import time

n = Notifications()

#while True:

n.sendAlert(0)

time.sleep(2)

n.sendAlert(1)


print "Test Complete, email should be sent"



