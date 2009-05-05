import socket
import SocketServer
import time
import select
import urllib
import shutil
from marshal import dumps, loads
import traceback
import cStringIO

marshalled_int_length = len(dumps(int(1)))		#length of a marshalled integer


class ConnectionClosedError(Exception): pass

LISTEN_PORT = 8086
PROXY_URL="http://isengard:9080/wk"



# Receive a precise number of bytes from a socket. Raises the
# ConnectionClosedError if  that number of bytes was not available.
# (the connection has probably been closed then).
# Never will this function return an empty message (if size>0).
# We need this because 'recv' isn't guaranteed to return all desired
# bytes in one call, for instance, when network load is high.
# Use a list of all chunks and join at the end: faster!
# (code taken from Pyro, http://pyro.sourceforge.net )
def sock_recv_msg(sock,size):
	try:
		msglen=0
		msglist=[]
		while msglen<size:
			chunk=sock.recv(size-msglen)
			if not chunk:
				raise ConnectionClosedError('connection lost-- no more data to read')
			msglist.append(chunk)	
			msglen+=len(chunk)
		return ''.join(msglist)
	except socket.error, x:
		raise ConnectionClosedError('connection lost-- socket error')


# Send a message over a socket. Raises ConnectionClosedError if the msg
# couldn't be sent (the connection has probably been lost then).
# We need this because 'send' isn't guaranteed to send all desired
# bytes in one call, for instance, when network load is high.
# (code taken from Pyro, http://pyro.sourceforge.net )
def sock_send_msg(sock,msg):
	size=len(msg)
	total=0
	try:
		sent=sock.send(msg)
		total+=sent
		if sent==0:
			raise ConnectionClosedError('connection lost -- nothing could be sent')
		while total<size:
			sent=sock.send(msg[total:])
			if sent==0:
				raise ConnectionClosedError('connection lost -- couldnt send more')
			total+=sent
	except socket.error, x:
		raise ConnectionClosedError('connection lost -- socket error')



class HTTPResponseError(Exception):
	def __init__(self, errcode, errmsg, headers, data=None):
		Exception.__init__(self)
		self.errcode=errcode
		self.errmsg=errmsg
		self.headers=headers
		self.data=data
		
class MyURLopener(urllib.URLopener):

    def http_error_default(self, url, fp, errcode, errmsg, headers, data=None):
    	data=fp.read()
    	raise HTTPResponseError(errcode, errmsg, headers, data)
        

#
#	The request handler. 
#	Processes requests that are coming from the WebKit adapter.
#
class WebWareHandler(SocketServer.BaseRequestHandler):
	def handle(self):
		## print "HANDLE REQ from",self.client_address
		try:
			requestData = self.receiveRequest(self.request)
			if requestData['format']=='CGI':
				startTime = time.time() # requestdata['time']
				self.handleRequest(self.request, requestData)
				requestTime = time.time()-startTime
				## print "END REQUEST, time taken=%.2f secs." % requestTime
			else:	
				print "Error: got unknown request format: "+requestData['format']
		except Exception,x:
			print "ERROR",x
			traceback.print_exc()
			self.request.shutdown(1)
			self.request.close()
		
	def receiveRequest(self, conn):
		chunk = sock_recv_msg(conn, marshalled_int_length)
		dict_length = loads(chunk)
		if type(dict_length) != type(1):
			conn.close()
			print "Error: Invalid AppServer protocol"
			return 0
		chunk = sock_recv_msg(conn, dict_length)
		return loads(chunk)

	def handleRequest(self, conn, requestdata):
		try:
			requestURI = "???"
			try:
				environ = requestdata['environ']
			
				# determine the request URI (path including query args)
				#requestURI = os.environ.get('REQUEST_URI')
				#if not requestURI:
				#scriptName = os.environ.get('SCRIPT_NAME')
				pathInfo = environ.get('PATH_INFO')
				queryString = environ.get('QUERY_STRING')
				# requestURI=scriptName+pathInfo
				requestURI=pathInfo
				if queryString:
					requestURI+='?'+queryString
				
				# extract HTTP headers
				headers={}
				headers['Accept']=environ.get("HTTP_ACCEPT")
				headers['Range']=environ.get("HTTP_RANGE")
				headers['Accept-Charset']=environ.get("HTTP_ACCEPT_CHARSET")
				headers['Accept-Encoding']=environ.get("HTTP_ACCEPT_ENCODING")
				headers['Accept-Language']=environ.get("HTTP_ACCEPT_LANGUAGE")
				headers['User-Agent']=environ.get("HTTP_USER_AGENT")
				headers['Cache-Control']=environ.get("HTTP_CACHE_CONTROL")
				headers['Content-Type']=environ.get("CONTENT_TYPE")
				headers['Pragma']=environ.get("HTTP_PRAGMA")
				headers['Referer']=environ.get("HTTP_REFERER")
				headers['Cookie']=environ.get("HTTP_COOKIE")
				#headers['Content-Length']=os.environ.get("CONTENT_LENGTH")
				#headers['Content-Disposition']=os.environ.get("CONTENT_DISPOSITION")
				
				# read any POST data
				if environ["REQUEST_METHOD"]=="POST":
					postdata = sock_recv_msg(conn, int(environ['CONTENT_LENGTH']))
				else:
					postdata=None
		
				self.transferServerRequest(requestURI, headers, postdata, conn)
		
			except Exception,x:
				print "ERROR",x
				traceback.print_exc()
				errorResult = 	"Status: 500 Internal server error\n" + \
								"Content-Type: text/plain\n\n" + \
								"Something went wrong with getting the required page.\n" + \
								"Error code: "+str(x)+"\n" + \
								"target url: "+PROXY_URL+requestURI+"\n\n"
				try:
					sock_send_msg(conn, errorResult)
				except:
					pass
		finally:
			conn.shutdown(1)
			conn.close()

	def transferServerRequest(self, requestURI, headers, postdata, output):
		# open the target URL
		urlopener=MyURLopener()
		
		# add original headers to target URL
		for k in headers.keys():
			if headers[k] is not None:
				urlopener.addheader(k, headers[k])
		
		# read the target URL, obtain HTTP reply headers
		targetURL=PROXY_URL+requestURI
		
		try:
			if postdata:
				page=urlopener.open(targetURL, data=postdata)
			else:
				page=urlopener.open(targetURL)
			headers=dict(page.headers)
			errcode=200
			errmsg="OK"
		except HTTPResponseError, ex:
			# there was a HTTP error such as 302 or 404. make sure we send this back.
			headers=dict(ex.headers)
			errcode=ex.errcode
			errmsg=ex.errmsg
			page=cStringIO.StringIO(ex.data)
			page.seek(0,2)  # seek to end
			
		
		# find the content-type
		contentType=headers.get('content-type') or headers.get('Content-Type') or headers.get('Content-type')
		if not contentType:
			headers['content-cype']='text/plain'
		
		# output the result HTTP headers
		resultStr="Status: %d %s\n" % (errcode, errmsg)
		for k in headers:
			resultStr+='%s: %s\n' % (k, headers[k])
		sock_send_msg(output, resultStr+'\n')
		
		try:
			# copy the document body, chunk-wise
			if page:
				shutil.copyfileobj(page, output.makefile("wb"))
		except Exception,x:
			print "ERROR DURING TRANSMIT:",x
			sock_send_msg(output, "\n\n\nERROR DURING READ/TRANSMIT OF DOCUMENT DATA: "+str(x)+"\n\n\n")


#
#	The actual server is just a threaded socket server.
#
webWareAdapter = SocketServer.ThreadingTCPServer( ('', LISTEN_PORT), WebWareHandler)

print "Starting WebWare (WebKit) adapter on port",LISTEN_PORT
webWareAdapter.serve_forever()

