# configuration for this webapp

from filemgr.users import FileUser
import filemgr.snakelets
import os

import logging
log=logging.getLogger("Snakelets.logger")

name="File Manager"
docroot="docroot"
sessionTimeoutSecs=30*60     # 30 minutes
sharedSession=False          # set to True, then also set Frog's one to True --> single signon

defaultOutputEncoding="UTF-8"


# The required privilege is "filemgr_access";
# this is set in the special filemgr user object (filemgr/users.py)
authorizationPatterns={ 
    "*": ["filemgr_access"],   
    "login.y": None,
    "cookiecheck.y": None,
    "about": None,
    "*.css": None,
    "*.js": None
}

def documentAllower(path):
    return True  # allow all (even .py files)

authenticationMethod = ("loginpage", "login.y")

snakelets= { 
    "download" : filemgr.snakelets.DownloadFile
}

configItems = {

    # The authorised users.
    # Use the 'mkuser.py' script to help adding new users!
    "knownusers" : {
        "user": FileUser("user", None, "/home/user", passwordhash="0000"),  # XXX set this to correct values
    },
    
}


#
#   USER AUTHORIZATION 
#
def authorizeUser(authmethod, url, username, password, request):
    if username in configItems["knownusers"]:
        user = configItems["knownusers"][username]
        if user.checkPassword(password):
            return user
    return None


#
#   WEBAPP INIT
#
def init(webapp):
    os.umask(0077) # protect written files, only readably by current user.
    import mimetypes
    mimetypes.types_map[".java"]="text/x-java-source"
    mimetypes.types_map[".log"]="text/x-logfile"
    mimetypes.types_map[".conf"]="text/x-configfile"
    mimetypes.types_map[".sh"]="text/x-shell-script"

    
def close(webapp):
    pass

