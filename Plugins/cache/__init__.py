#############################################################################
#
#	$Id: __init__.py,v 1.9 2005/05/01 17:18:10 irmen Exp $
#	Page caching plugin
#
#	This is part of "Snakelets" - Python Web Application Server
#	which is (c) Irmen de Jong - irmen@users.sourceforge.net
#
#############################################################################

from snakeserver.plugin import ServerPlugin, RequestPlugin, SEQUENCE_FIRST, SEQUENCE_LAST
import time

#
#   A Page-Cache plugin that hooks into the request processing
#   logic and can cache the results of dynamic pages.
#   It uses a list of page urls that must be cached (and the timeout)
#   so you have to add urls yourself, using the addCacheURL method.
#

ENABLED=True
PLUGINS=[ "PageCacher", "PageCacher_post" ]


CACHE_URLS = { }   # dict of url-->timeoutperiod, default=don't cache anything.
CACHE={}

class CacheEntry:
    def __init__(self, timeout, content, encoding, contenttype, contentdisposition, httpheaders):
        self.time=time.time()
        self.timeout=timeout
        self.content=content   # this is the page data
        self.encoding=encoding
        self.ctype=contenttype
        self.cdisp=contentdisposition
        self.httpheaders=httpheaders
    def age(self):
        return time.time()-self.time
    def valid(self):
        return self.age() < self.timeout



class PageCacher(RequestPlugin):
    # PLUGIN_NAME="PageCacher"    # the class name is correct so we can use that
    PLUGIN_SEQ = SEQUENCE_FIRST
    CACHE_HEADER="X-Snakelets-Cached"   # special flag header
    def plug_init(self,server):
        print "Page cache plugin installed"
        
    # Check if the called page is available in the cache, if so, 
    # return the cached result (but only if it is not out of date).
    def plug_requestExecute(self, webapp, snakelet, request, response):
        global CACHE
        try:
            entry = CACHE[ request.getRequestURL() ]
            if entry.valid():
                response.setHeader(self.CACHE_HEADER,"yes; age=%d" % entry.age())
                if entry.encoding:
                    response.setEncoding(entry.encoding)
                if entry.ctype:
                    response.setContentType(entry.ctype)
                if entry.cdisp:
                    response.setContentDisposition(entry.cdisp)
                for (hdr,value) in entry.httpheaders.items():
                    response.setHeader(hdr,value)
                return entry.content
            else:
                # Page in cache is too old; remove from cache and serve original page again.
                del CACHE[ request.getRequestURL() ]
        except KeyError:
            # no cached output yet.
            pass
        return False # contiune with other plugins, if any
        
    def plug_requestFinished(self, webapp, snakelet, request, response, outputarray=[None]):
        # Don't call more plugins (=when we return 'true') if cached result was returned, 
        # so test if the flag header was set
        return self.CACHE_HEADER in response.userHeaders   

    # you can call the following method to add urls to cache.
    # obtain a reference to this plugin, and call this method
    # (for instance, from the init code of your webapp).
    def addCacheURL(self, url, timeout):
        global CACHE_URLS
        CACHE_URLS[url]=timeout


class PageCacher_post(RequestPlugin):
    # PLUGIN_NAME="PageCacher_post"    # the class name is correct so we can use that
    PLUGIN_SEQ = SEQUENCE_LAST
    def plug_init(self,server):
        pass
        
    # If the requested page is in the list of urls that must be cached,
    # store the output data of the page in the cache. 
    def plug_requestFinished(self, webapp, snakelet, request, response, outputarray=[None]):
        global CACHE_URLS, CACHE
        url=snakelet.getURL()
        if url in CACHE_URLS:
            if outputarray[0]:
                timeout = CACHE_URLS[url]
                url = request.getRequestURL()
                if not CACHE.has_key(url):
                    # The page is not yet in the cache, so put it in.
                    CACHE[ url ] = CacheEntry(timeout, outputarray[0].getvalue(), response.content_encoding, response.content_type, response.content_disposition, response.userHeaders)
            else:
                # there is no output object so we cannot obtain the page content to cache...
                print "page has no output object, cannot cache:",url
            return True  # no more plugins after us!
        else:
            return False

