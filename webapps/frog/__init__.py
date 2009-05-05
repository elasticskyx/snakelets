# configuration for this webapp

from snakeserver.user import LoginUser
from snakeserver.httpauth import AuthError
import frog.snakelets
import frog.objects
import frog
import os, time

import logging
log=logging.getLogger("Snakelets.logger")

FILEMGR_WEBAPP = "filemgr"

#
#   THE USER-CHANGABLE CONFIGURATION ITEMS.
#   PLEASE UPDATE THESE TO YOUR OWN SITUATION (SUCH AS E-MAIL ADDRESS)
#   BEFORE STARTING FROG. 
#
configItems = {

    # THE STORAGE LOCATION FOR ALL BLOG DATA AND CONTENT FILES
    "storage" : "blogdata",
    "files"   : "blogfiles",

    # The Administrator users.
    "adminusers" : { "admin": LoginUser("admin","admin",name="Frog Admin", privileges=[frog.USERPRIV_ADMIN]) },

    # The user that you will be redirected to when accessing the '/' url. None=multiuser portal.
    "rootdiruser": None,
    
    # Edit this to make a file manager link appear on the submit page, remove this to disable the menu item
    "filemgr-url":      "/"+FILEMGR_WEBAPP+"/", 
    
    # Website Admin contact information
    "site-admin-name":      "{change this site-admin-name string}",
    "site-admin-contact":   "{change this site-admin-contact string}",

    # Mail settings   >>>CHANGE THESE<<<
    "mail-smtp-host":       None,       # leave None to NOT use e-mail, otherwise give the smtp server name
    "mail-smtp-user":       None,       # smtp username if login is required on the server
    "mail-smtp-password":   None,       # smtp password 
    "mail-sender":          None,       # default sender address (>>>MUST BE FILLED IN <<<)
    "mail-replyto":         None,       # default replyto address

    # Various other settings. You don't usually have to change these.
    "antispam":                     True,
    "antispam_updateperiod_mins":   60,    # minutes.
    "allowdeeplinks":               False,
    "articlecount_updateperiod":    60,    # sec
    "blogentrydate_updateperiod":   55,    # sec
    "articlesinmonth_updateperiod": 65,    # sec
    "activearticles_updateperiod":  75,    # sec
    "rssfeeds_updateperiod":  		10*60,    # sec
    "archivemenu_nummonths":        4,
    
  }



name="Frog blogger"
docroot="docroot"
assetLocation="."

sessionTimeoutSecs=30*60     # 30 minutes
sharedSession=False          # set to True, then also set Filemgr's one to True --> single signon

defaultOutputEncoding="UTF-8"

authorizationPatterns={
    "admin/*": [frog.USERPRIV_ADMIN],               # administrative screens 
    "admin/login.y": None,
    "blog/submit.y": [frog.USERPRIV_BLOGGER],       # various screens that you can only see if you have blogging privs
    "blog/editcomment.y": [frog.USERPRIV_BLOGGER],
    "blog/customize.y": [frog.USERPRIV_BLOGGER],
  }

# Note that the authmethod is defined in the various pages themselves,
# instead of defining a global auth method for the whole webapp here.


snakelets= {
    "user": frog.snakelets.User,
    "currentcaptcha.jpg": frog.snakelets.Captcha,
    "articlestats.sn": frog.snakelets.ArticleStats,
    "files": frog.snakelets.FileServ,
    "feeds/*/feed.*": frog.snakelets.RSSFeeder,
  }


#
#   USER AUTHORIZATION 
#
#   1) check for adminusers, defined above 
#   2) check for 'normal' registered blog users
#
def authorizeUser(authmethod, url, username, password, request):
    def validateUser(storageEngine, username, password, useCache=True):
        if storageEngine.isRegisteredUser(username, useCache):
            user=storageEngine.loadUser(username)
            if user.checkPassword(password):
                return user
        return None
    webapp=request.getWebApp().getName()[0]
    if webapp=="frog":
        # it's us; try admin first, then load a user via the session's storage engine
        if username in configItems["adminusers"]:
            user = configItems["adminusers"][username]
            if user.checkPassword(password):
                return user
        if hasattr(request.getSessionContext(), "storageEngine"):
            storageEngine=request.getSessionContext().storageEngine
            return validateUser(storageEngine, username, password, False)
        return None
    elif webapp==FILEMGR_WEBAPP:
        # it's the filemgr webapp, try to load a user via the global storage engine
        # (because the session is not a Frog session and doesn't have it)
        storageEngine=request.authorizingWebApp.getContext().storageEngine
        user=validateUser(storageEngine, username, password)
        # only ok if it is a true Blogger user and if the password matches (obviously)
        if user and user.accounttype==frog.ACCOUNTTYPE_BLOGGER: 
            # auth okay! Now set the datafiles directory (needed by filemgr)
            user.directory=os.path.join(request.authorizingWebApp.getConfigItem("files"), user.userid)
            return user
    else:
        raise AuthError("Frog: invalid webapp asking for authorization: "+webapp)

#
#   WEBAPP INIT
#
#   Checks versions, storage directory.
#   Places storage engine's Class on the app Context.
#
def init(webapp):
    print "INIT FROG WEBAPP" # XXX
    import frog
    log.info(">> INIT FROG "+frog.VERSION)
    os.umask(0077) # protect written files, only readably by current user.
    storage = webapp.getConfigItem("storage")
    storage=os.path.expanduser(storage)
    storage=os.path.abspath(storage)
    if not os.access(storage, os.W_OK):
        msg="The storage directory does not exist or isn't writable: "+storage
        print
        print ">>>",msg
        print
        raise IOError(msg)
    print "Frog: using storage path:",storage
    webapp.getConfigItems()["storage"] = storage
    files = webapp.getConfigItem("files")
    files=os.path.expanduser(files)
    files=os.path.abspath(files)
    if not os.access(files, os.W_OK):
        msg="The files directory does not exist or isn't writable: "+files
        print
        print ">>>",msg
        print
        raise IOError(msg)
    print "Frog: using files path:",files
    webapp.getConfigItems()["files"] = files

    from frog.objects import StorageEngine
    log.info("Using Storage Engine: "+str(StorageEngine))
    webapp.getContext().storageEngine = storageEngine = StorageEngine(webapp)   # global engine, not user-specific

    # check if admin accounts are not the same as blog users (this is currently not supported)
    users=storageEngine.listUsers(False)
    for username in webapp.getConfigItems()["adminusers"]:
        if username in users:
            msg="admin user(s) can not be the same as normal blog users"
            print "Frog error:",msg
            raise AuthError(msg)

    # initialise the mail server
    if webapp.getConfigItem("mail-smtp-host"):
        import util.mailer
        server=webapp.getContext().MailServer=util.mailer.MailServer( 
                webapp.getConfigItem("mail-smtp-host"),
                webapp.getConfigItem("mail-smtp-user"),
                webapp.getConfigItem("mail-smtp-password"),
                webapp.getConfigItem("mail-sender"),
                webapp.getConfigItem("mail-replyto") )
        log.info("Initialised the mail server")
    else:
        msg="Not using a mail server; no comment mail-notificaton will be done"
        log.warn(msg)
        print "Frog: !!",msg

    # initialise the task scheduler
    import util.kronos
    Scheduler=util.kronos.ThreadedScheduler()
    webapp.getContext().Scheduler = Scheduler
    Scheduler.start()
    
    # initialise the anti-spam measures
    if webapp.getConfigItem("antispam"):
        from frog.antispam.blacklist import MTBlackList
        storage = webapp.getConfigItem("storage")
        webapp.getContext().AntiSpam = MTBlackList(storage)    # this may fail...
        # setup a refresh loop with the scheduler, once per x hours
        interval=webapp.getConfigItem("antispam_updateperiod_mins")*60
        Scheduler.add_interval_task(webapp.getContext().AntiSpam.update, "AntiSpam update", 10, interval, Scheduler.method.threaded, [], None)
        log.info("Installed anti-spam: "+str(webapp.getContext().AntiSpam))

    else:
        log.warn("No anti-spam installed")

    
def close(webapp):
    log.info(">> CLOSE DOWN FROG WEBAPP")

