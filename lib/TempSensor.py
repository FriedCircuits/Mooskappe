#! /usr/bin/python
#Handles reading temp sensor

from time import sleep
from ds18b20 import DS18B20
import config
from lib.Notifications import Notifications


#Returns current temp in C, F, K
def getTemp(temp):
    if(config.TEMP_ENABLED):
        sensor = DS18B20()
        temperatures = sensor.get_temperatures([DS18B20.DEGREES_C, DS18B20.DEGREES_F, DS18B20.KELVIN])
        if(temp == 0): return str(temperatures[1])
        if(temp == 1): return str(temperatures[0])

        return temperatures

    return 'No Sensor'

#Checks temp and sends alart
def checkTemp():
        if(config.TEMP_ENABLED):
            sensor = DS18B20()
            temperatures = sensor.get_temperatures([DS18B20.DEGREES_C, DS18B20.DEGREES_F, DS18B20.KELVIN])
            if(temperatures[1] >= config.TEMP_MAX_F) or (temperatures[0] >= TEMP_MAX_C):
                n = Notifications()
                n.sendAlert(3)
                

        
    
