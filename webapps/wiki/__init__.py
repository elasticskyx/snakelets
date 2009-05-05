# configuration for this webapp

name="Python wiki static files"

# NOTE: you should make a copy of the "htdocs" directory of the moinmoin's wiki
# inside this webapp. This directory contains all static files such as CSS
# and images that MoinMoin will refer to.
docroot="htdocs"

snakelets= {}
configItems = {}
authorizationPatterns = {}
 
def init(webapp):
	pass
    
def close(webapp):
	pass
