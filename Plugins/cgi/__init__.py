#############################################################################
#
#	$Id: __init__.py,v 1.1 2005/06/28 18:57:24 irmen Exp $
#	PageProcessor plugin that handles .cgi
#
#	This is part of "Snakelets" - Python Web Application Server
#	which is (c) Irmen de Jong - irmen@users.sourceforge.net
#
#############################################################################

from snakeserver.plugin import PageProcessorPlugin, SEQUENCE_NORMAL
from snakeserver.webapp import WebApp
import snakeserver.request_response as request_response


#
#   A PageProcessor plugin that hooks into the request processing
#   logic and will run cgi scripts.
#

ENABLED=True
PLUGINS=[ "CGIPlugin" ]


class CGIProcessor(WebApp.PageProcessor):
    def do_HEAD(self):
        # CGI HEAD is not supported
        self.handler.send_error(405, userHeaders={"Allow": "GET, PUT"} )
    def do_GET(self, passthroughRequest, passthroughResponse, timeoutpage=False):
        print "CGI GET"
        request=response=None
        try:
            response = passthroughResponse or request_response.Response(self.webapp,self.handler,self.handler.wfile)
            if passthroughRequest:
                request=passthroughRequest
            else:
                request=request_response.Request(self.webapp, self.pathinfo, self.args, self.handler, self.handler.rfile)
            response.sendError(501) # XXX not yet implemented
        except EnvironmentError,x:
            self.handler.send_error(404)
        except Exception,x:
            self.webapp.reportSnakeletException(None, x, self.handler, self.handler.wfile, request, response, None)
    def do_POST(self):
        print "CGI POST"
        request=request_response.Request(self.webapp, self.pathinfo, self.args, self.handler, self.handler.rfile)
        response=request_response.Response(self.webapp,self.handler,self.handler.wfile)
        response.sendError(501) # XXX not yet implemented


class CGIPlugin(PageProcessorPlugin):
    PLUGIN_SEQ = SEQUENCE_NORMAL
    def plug_init(self,server):
        print "CGI plugin installed"
    def plug_getPageProcessor(self, webapp, handler, url, pathpart, query):
        print "CGI PLUGIN:"
        print " wa=",webapp
        print " handler=",handler
        print " url=",url
        print " pathpart=",pathpart
        print " query=",query
        if pathpart.endswith(".cgi"):
            print "GOT CGI"
            return CGIProcessor(webapp,handler,url,pathpart,query)
        # if you have your own page processor, return it, otherwise return None
        return None
