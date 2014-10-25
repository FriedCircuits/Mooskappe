
#!/usr/bin/python

from Adafruit_CharLCDPlate import Adafruit_CharLCDPlate
from time import sleep

if __name__ == '__main__':

    lcd = Adafruit_CharLCDPlate()
    lcd.begin(16, 2)
    lcd.clear()
    lcd.message("FriedCircuits.us\nMooskappe v1.0")
    sleep(2)
    lcd.backlight(lcd.RED)
    sleep(2)
    lcd.backlight(lcd.GREEN)
    sleep(2)
    lcd.backlight(lcd.YELLOW)
    sleep(2)
    lcd.backlight(lcd.VIOLET)
    sleep(2)
    lcd.backlight(lcd.BLUE)
