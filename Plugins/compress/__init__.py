#############################################################################
#
#	$Id: __init__.py,v 1.11 2005/05/16 14:16:04 irmen Exp $
#	HTTP gzip compression plugin
#
#	This is part of "Snakelets" - Python Web Application Server
#	which is (c) Irmen de Jong - irmen@users.sourceforge.net
#
#############################################################################

from snakeserver.plugin import ServerPlugin, RequestPlugin, SEQUENCE_LATE
import cStringIO, gzip, zlib

#
#   A compressor plugin that hooks into the request processing
#   logic and that compresses the response data of certain requests.
#   (for .html, .txt and .y pages only -- things like images will
#    not be processed because usually there's nothing to compress).
#
#   NOTE: the RequestPlugin is only called for dynamic pages, not
#         for pages that are served as static files.
#         So for static files no compression is done (by this plugin)!
#

ENABLED=True
PLUGINS=[ "ResponseCompressor" ]

SUFFIXES = [ ".html",".htm",".txt",".y" ]
COMPRESSLEVEL = 4 #  try: zlib.Z_DEFAULT_COMPRESSION ,  zlib.Z_BEST_SPEED

class ResponseCompressor(RequestPlugin):
    # PLUGIN_NAME = "ResponseCompressor"  # the classname is okay so use that
    PLUGIN_SEQ = SEQUENCE_LATE
    def plug_init(self,server):
        print "HTTP gzip compressor installed"
    def plug_requestFinished(self, webapp, snakelet, request, response, outputarray=[None]):
        if outputarray[0] and filter(request.getRequestURLplain().lower().endswith, SUFFIXES):
            if not response.used():
                # The response has not yet begun sending,
                # so we can safely compress the output and add a new encoding header.
                # So, let us check if the client accepts gzip encoding:
                hdr = request.getHeader('accept-encoding') 
                if hdr and hdr.find("gzip") != -1:
                    outputarray[0].seek(0)  # rewind the output stream
                    databefore=outputarray[0].read()
                    before=len(databefore)
                    dataafter=self.compressBuf(databefore)
                    after=dataafter.tell()
                    if after<before:
                        # only replace the output data if the compressed data is smaller
                        response.setHeader("Content-Encoding","gzip")
                        outputarray[0]=dataafter
        return False  # continue with other plugins, if any

    def compressBuf(self, buf):
        zbuf = cStringIO.StringIO()
        zfile = gzip.GzipFile(mode = 'wb',  fileobj = zbuf, compresslevel = COMPRESSLEVEL)
        zfile.write(buf)
        zfile.close()
        return zbuf

