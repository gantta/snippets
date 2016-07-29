
import tornado.ioloop
import time

from tornado import gen

# Shutdown the IOLoop cleanly
def sig_handler(sig, frame):
    tornado.ioloop.IOLoop.instance().add_callback(shutdown)

def shutdown():
    MAX_WAIT_SECONDS_BEFORE_SHUTDOWN = 20
    io_loop = tornado.ioloop.IOLoop.instance()
    deadline = time.time() + MAX_WAIT_SECONDS_BEFORE_SHUTDOWN
    def stop_loop():
        now = time.time()
        if now < deadline and (io_loop._callbacks or io_loop._timeouts):
            io_loop.add_timeout(now + 1, stop_loop)
        else:
            io_loop.stop()
    stop_loop()
    sys.exit(0)

if __name__ == '__main__':

    # register signal handlers
    signal.signal(signal.SIGTERM, sig_handler)
    signal.signal(signal.SIGINT, sig_handler)

    @gen.coroutine
    def send_data():
        reader.read_once()
        HTTPRequest.send(reader.getAndClear())
        #board.blink("blue")

    # schedule all the callbacks
    tornado.ioloop.PeriodicCallback(send_data, GLOBALS['postInterval']).start()
    tornado.ioloop.PeriodicCallback(reader.read, GLOBALS['pollInterval']).start()
    #tornado.ioloop.PeriodicCallback(board.reset_wifi, GLOBALS['buttonInterval']).start()
    tornado.ioloop.IOLoop.instance().start()
