# configuration for this webapp

# NOTE : this webapp is only for the actual wiki pages, the static content
# such as images and CSS will be refered to by a different url.
# Usually this is "/wiki/*" and that's why the static content is put
# inside the "wiki" webapp (and not here).
# NOTE: you DO NEED TO COPY wikiconfig.py to this webapp directory!

import MoinMoin.version
import MoinMoin.log
MoinMoin.log.configured=True    # force MoinMoin to use OUR logging config instead!
import logging
import sys
log=logging.getLogger("Snakelets.logger")

try:
    import wikiconfig
except ImportError,x:
    msg="Can't import wikiconfig - not copied in webapp dir? error="+str(x)
    log.error(msg)
    print >>sys.stderr, msg
    raise

import wikisnakelets.wiki


name="Python wiki stub"
docroot="."

snakelets= {
	"index.sn": wikisnakelets.wiki.MoinMoin,
	"*": wikisnakelets.wiki.MoinMoin,
	}

configItems = {}

authorizationPatterns = {}

       
def init(webapp):
    log.info("Wiki webapp using "+MoinMoin.version.project+" "+MoinMoin.version.release)
    log.info("Wiki name: "+wikiconfig.Config.sitename)
    
def close(webapp):
	pass
