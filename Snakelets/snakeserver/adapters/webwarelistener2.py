import socket
import time
import select

from marshal import dumps, loads


int_length = len(dumps(int(1)))		#length of a marshalled integer


class WebWareAdapter:
	def __init__(self):
		self.port = 8086
		self.insock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		self.insock.bind(('',self.port))
		self.insock.listen(1)
		print "******** Listening to WebWare Socket ************"

	def handleRequest(self):

		startTime = time.time()
		print 'BEGIN REQUEST'
		print time.asctime(time.localtime(startTime))
		conn = self.sock
		print 'receiving request from', conn

		BUFSIZE = 8*1024


		chunk = ''
		missing = int_length
		while missing > 0:
			block = conn.recv(missing)
			if not block:
				conn.close()
				raise socket.error, 'received only %d out of %d bytes when receiving dict_length' % (len(chunk), int_length)
			chunk = chunk + block
			missing = int_length - len(chunk)
		dict_length = loads(chunk)
		if type(dict_length) != type(1):
			conn.close()
			print "Error: Invalid AppServer protocol"
			return 0

		chunk = ''
		missing = dict_length
		while missing > 0:
			block = conn.recv(missing)
			if not block:
				conn.close()
				raise socket.error, 'received only %d out of %d bytes when receiving dict' % (len(chunk), dict_length)
			chunk = chunk + block
			missing = dict_length - len(chunk)

		dict = loads(chunk)

		return dict


	def listen(self):
		while 1:
			ins,outs,excs=select.select([self.insock],[],[])
			if self.insock in ins:
				(self.sock,addr )=self.insock.accept()
				print "GOT REQUEST FROM ",addr
				data=self.handleRequest()
				
				self.sock.send("resultaat")
				print "END OF REQUEST"
				try:
					self.sock.shutdown(1)
					self.sock.close()
				except:
					pass

				
w=WebWareAdapter()
w.listen()
