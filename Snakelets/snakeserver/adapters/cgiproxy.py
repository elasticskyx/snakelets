#! /usr/bin/env python
#
#	CGI proxy script
#
#	Written by Irmen de Jong -- irmen@users.sourceforge.net
#
#	Usage:
#	This cgi script passes any GET or POST action that goes
#	trough it along to another URL (the proxied URL).
#	Results are passed back to the original user agent.
#	Tries hard to replicate HTTP headers, and also handles POST data.
#
#	You can configure the proxied location by editing
#	the PROXY_URL below.
#

import cgi,os,sys
import cgitb
import urllib
import shutil

# The proxied URL, all requests are passed to here:
# (including path info, query string, HTTP headers and POST data)
PROXY_URL = "http://isengard:9080/proxy.py"


cgitb.enable()

# determine the request URI (path including query args)
#requestURI = os.environ.get('REQUEST_URI')
#if not requestURI:
#scriptName = os.environ.get('SCRIPT_NAME')
pathInfo = os.environ.get('PATH_INFO')
queryString = os.environ.get('QUERY_STRING')
# requestURI=scriptName+pathInfo
requestURI=pathInfo
if queryString:
	requestURI+='?'+queryString

# extract HTTP headers
headers={}
headers['Accept']=os.environ.get("HTTP_ACCEPT")
headers['Range']=os.environ.get("HTTP_RANGE")
headers['Accept-Charset']=os.environ.get("HTTP_ACCEPT_CHARSET")
headers['Accept-Encoding']=os.environ.get("HTTP_ACCEPT_ENCODING")
headers['Accept-Language']=os.environ.get("HTTP_ACCEPT_LANGUAGE")
headers['User-Agent']=os.environ.get("HTTP_USER_AGENT")
headers['Cache-Control']=os.environ.get("HTTP_CACHE_CONTROL")
headers['Content-Type']=os.environ.get("CONTENT_TYPE")
headers['Pragma']=os.environ.get("HTTP_PRAGMA")
headers['Referer']=os.environ.get("HTTP_REFERER")
headers['Cookie']=os.environ.get("HTTP_COOKIE")
#headers['Content-Length']=os.environ.get("CONTENT_LENGTH")
#headers['Content-Disposition']=os.environ.get("CONTENT_DISPOSITION")

# read any POST data
if os.environ["REQUEST_METHOD"]=="POST":
	postdata=sys.stdin.read()
else:
	postdata=None

# open the target URL
urlopener=urllib.FancyURLopener()

# add original headers to target URL
for k in headers.keys():
	if headers[k] is not None:
		urlopener.addheader(k, headers[k])

# read the target URL, obtain HTTP reply headers
try:
	targetURL=PROXY_URL+requestURI
	if postdata:
		page=urlopener.open(targetURL, data=postdata)
	else:
		page=urlopener.open(targetURL)
except IOError,x:
	print "Content-Type: text/plain"
	print
	print "Something went wrong with getting the required page:",x[0]
	print "code:",x[1],x[2]
	print "target url:",targetURL
	print
	raise SystemExit

headers=dict(page.headers)

# find the content-type
contentType=headers.get('content-type') or headers.get('Content-Type') or headers.get('Content-type')
if not contentType:
	headers['Content-Type']='text/plain'

# output the result HTTP headers
for k in headers:
	sys.stdout.write( '%s: %s\n' % (k, headers[k]) )
sys.stdout.write('\n')

# copy the document body, chunk-wise
shutil.copyfileobj(page, sys.stdout)
