
# Import stuff

import datetime
import time

class myClass(object):
    someVarArray = { "arg1" :[], "arg2" :[], "arg3" :[] }
    
    def __init__():
       values = {}
       super(myclass,self).__init__()
    
    def do_something(self);
        try:
            values = {}
            Tools.log(str(values))
        except IOError, e:
            Tools.log('I/O Error reading whatever it is I was supposed to be reading. Exception %s' % str(e), 1)
        except Exception, e:
            Tools.log('Error doing something: %s' % str(e), 1)
            pass

    def do_something_else(self):
        try:
            values = {}
            values['arg1'] = 'this'
            values['arg2'] = 'that'
            Tools.log(str(values))
        except IOError, e:
            Tools.log('I/O Error reading whatever it is I was supposed to be reading. Exception %s' % str(e), 1)
        except Exception, e:
            Tools.log('Error doing something: %s' % str(e), 1)
            pass