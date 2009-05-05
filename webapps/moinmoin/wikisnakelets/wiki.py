from wikiconfig import Config
from MoinMoin.request import RequestBase
from snakeserver.snakelet import Snakelet
from snakeserver.webform import FormUploadedFile, FormFileUploadError
import socket
import logging

log=logging.getLogger("Snakelets.logger")

class MoinRequest(RequestBase):
    """The request object that adapts a Snakelets request to a Moin request"""
    def __init__(self, snake, request, response, properties={}):
        self.snake=snake
        self.request=request
        self.response=response
        self.request_uri = request.getRequestURL()
        self.script_name = self.snake.getWebApp().getURLprefix()[:-1] # strip the trailing /
        self.path_info, self.query_string = self.splitURI(request.getRequestURL())
        self.path_info = self.path_info[len(self.script_name):]
        self.saved_cookie = request.getCookie()
        self.request_method = request.getMethod()
        headers = request.getAllHeaders()
        self.remote_addr=request.getRemoteAddr()
        self.http_user_agent=request.getUserAgent()
        self.http_accept_language = headers.getheader('accept-language')
        self.setHttpReferer(headers.getheader('referer'))
        self.setHost(headers.getheader('host'))
        self.setURL(headers)
        self.if_modified_since=headers.getheader('If-modified-since')
        self.if_none_match=headers.getheader('If-none-match')
        self.server_port = str(request.getServerPort())
        self.server_name = request.getServerName()
        if ':' in self.server_name:
            self.server_name=self.server_name.split(':')[0]
        self.headers = headers
        baseurl = request.getBaseURL()
        self.is_ssl = baseurl.startswith("https") or baseurl.startswith("HTTPS")
        RequestBase.__init__(self, properties)

    def _setup_args_from_cgi_form(self, form=None):
        try:
            snakeletsForm=self.request.getForm()
        except FormFileUploadError,x:
            print "Error processing uploaded file:",x
            self.response.setResponse(413, str(x))
            raise
        moinForm = {}
        for key,value in snakeletsForm.items():
            if not (isinstance(value, list) or isinstance(value,tuple)):
                moinForm[key] = [value]
            else:
                moinForm[key] = value
            if isinstance(value, FormUploadedFile):
                data = value.file.read()
                moinForm[key] = [data]
                moinForm[key+"__filename__"] = value.filename   # special form field with the file's name.
        return moinForm

    def getScriptname(self):
        return self.script_name

    def read(self, n=None):
        # n = amount to read, or None
        print "XXX read() not yet implemented in MoinRequest"  # XXX
        raise NotImplementedError("read() not yet implemented in MoinRequest")

    def write(self, *data):
        out = self.response.getOutput()
        data=self.encode(data)
        try:
            out.write(data)
        except socket.error,x:
            log.debug("socket write error: "+str(x))

    def reset_output(self):
        print "XXX reset_output() not yet implemented in MoinRequest" # XXX
        raise NotImplementedError("reset_output() not yet implemented in MoinRequest")

    def http_redirect(self,url):
        url=self.getQualifiedURL(url)
        self.emit_http_headers(["Status: 302 Found", "Location: %s" % url])
        self.response.HTTPredirect(url)   # snakelets way of doing a redirect

    def _emit_http_headers(self, headers):
        """ private method to send out preprocessed list of HTTP headers """
        st_header, ct_header, other_headers=headers[0],headers[1],headers[2:]
        status=st_header.split(':',1)[1].lstrip()
        contenttype=ct_header.split(':',1)[1].lstrip()
        status, msg = status.split(' ',1)
        status=int(status)
        self.response.setResponse(status, msg)
        self.response.setContentType(contenttype)
        for header in other_headers:
            key,value=header.split(':',1)
            value=value.lstrip()
            if key.lower()=="content-length":
                self.response.setEncoding(None)
                self.response.setContentLength(int(value))
            elif key.lower()=="content-disposition":
                self.response.setContentDisposition(value)
            else:
                self.response.setHeader(key,value)

    def flush(self):
        pass

    def finish(self):
        # do nothing with out, but just force the correct processing of headers etc,
        # in the case where no page content has been generated.
        out=self.response.getOutput()


class MoinMoin(Snakelet): 
    """The snakelet that turns all requests into Moin requests"""
    def getDescription(self):
        return "MoinMoin Wiki"
    def requiresSession(self):
        return self.SESSION_WANTED
    def serve(self, request, response):
        request.setEncoding("UTF-8")
        # response.setEncoding("UTF-8")   # <-- don't set response encoding, MoinMoin will take care of this
        url=request.getRequestURL()
        if url.endswith("/index.html") or url.endswith("index.sn") or url.endswith('/'):
            response.HTTPredirect(Config.page_front_page)
        else:
            req = MoinRequest(self, request, response)
            req.run()
