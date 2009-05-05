#############################################################################
#
#	$Id: __init__.py,v 1.5 2005/05/01 17:18:10 irmen Exp $
#	Shared Authentication plugin
#
#	This is part of "Snakelets" - Python Web Application Server
#	which is (c) Irmen de Jong - irmen@users.sourceforge.net
#
#############################################################################

from snakeserver.plugin import ServerPlugin
import logging
import weakref

log=logging.getLogger("Snakelets.logger")


#
#   Plugin to facilitate cross-webapp authentication (shared authentication)
#   so that different webapps can use a single authentication method
#   and a single userbase.
#   Note that single-signon (so that the user only has to log in one time,
#   and that other webapps share the login info) is not and cannot be done
#   by this service. You have to configure sharedSession for that.
#
#   When the authorization method from another webapp is called, there
#   is a special field in the Request object: authorizingWebApp
#   which is set to the authorizing webapp object. This is useful because
#   often the authorization method needs "its own" webapp to do stuff,
#   and the webapp from the Request object is not its own, in this case!
#
ENABLED=True
PLUGINS=[ "SharedAuth" ]      # this MUST be the name ("SharedAuth"); the server looks for this

class SharedAuth(ServerPlugin):
    # PLUGIN_NAME="SharedAuth" # the classname is correct so use that
    # PLUGIN_SEQ=... # default sequence is just fine
    def plug_init(self,server):
        log.debug("Shared Auth plugin init")
        self.webappMapping=weakref.WeakValueDictionary()    # webapp name string->webapp obj
    def plug_sessionCreated(self, webapp, session, request):
        pass
    def plug_sessionDestroyed(self, webapp, session, request):
        pass

    def addWebappMapping(self, srcWebappName, targetWebappObj):
        self.webappMapping[srcWebappName]=targetWebappObj
        
    def authorizeUser(self, authmethod, url, username, password, request):
        name=request.getWebApp().getName()[0]
        target=self.webappMapping.get(name)
        if target and target.authorizeUser:
            request.authorizingWebApp = target   # for easy reference from the auth method
            return target.authorizeUser(authmethod, url, username, password, request)
        return None

