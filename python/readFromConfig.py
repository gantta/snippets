'''

Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

    http://aws.amazon.com/apache2.0/

or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

Note: Other license terms may apply to certain, identified software files contained within or
distributed with the accompanying software if such terms are included in the directory containing
the accompanying software. Such other license terms will then apply in lieu of the terms of the
software license above.
'''


import ConfigParser
import os

# The config parser ingests the SBS configuration file
config = ConfigParser.ConfigParser()
if os.path.isfile('sbs.cfg'):
    config.read('sbs.cfg')
else:
    exit('No config file could be found. Please try running python Setup.py')

GATEWAY_ID = config.get('sbs', 'gateway-id')
GLOBALS['sbsunit'] = config.get('sbs', 'gateway-id')

# Thresholds
THRESHOLDS = {
        "sound": config.get('threshold', 'sound'),
        "ultrasonic": config.get('threshold', 'ultrasonic'),
        "temp": config.get('threshold', 'temp')
    }

# This dictionary holds all of the pin outs for the devices connected to the board.
PINS = {
    "led": {
        "green": config.getint('leds', 'green'),
        "blue": config.getint('leds', 'blue'),
        "red": config.getint('leds', 'red')
    },
    "sensors" : {
        "sound-sensor": config.getint('sensors', 'sound-sensor'),
        "flow-sensor": config.getint('sensors', 'flow-sensor'),
        "ultrasonic-ranger": config.getint('sensors', 'ultrasonic-ranger'),
        "dht": config.getint('sensors', 'dht-sensor'),
        "temp-sensor": config.getint('sensors', 'temp-sensor'),
        "led-bar": config.getint('sensors', 'led-bar')
    },
    "buttons": {
        "reset-wifi": config.getint('buttons', 'reset-wifi')
    }}

# The maximum buffer size to hold before culling records.
GLOBALS['maxBuffer'] = config.get('misc', 'max-buffer-size')

# The number of errors that need to occur before the application slows post speed.
GLOBALS['maxErrorCount'] = config.get('misc', 'error-count')

# Initialize the HTTPRequest object with the API Key and Content Type.
HTTPRequest.init(config.get('api', 'key'), config.get('api', 'content-type'), config.get('api', 'endpoint') + GATEWAY_ID + "/data")
