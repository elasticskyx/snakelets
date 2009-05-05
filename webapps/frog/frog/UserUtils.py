#
#   Utilities for creating/updating a user account
#   This is an Ypage base class. (The search page inherits from this class)
#

import frog.objects, frog.util
import os, re
import urllib

import logging
log=logging.getLogger("Snakelets.logger")

USERNAME_PATTERN = "^[a-z0-9!@#$^()\\[\\]{}_\\-+. <>'\"&]+$"



class UserAccount:
    
    def validateAccountData(self, username, password, password2, accounttype):
        if not username:
            return "<p><strong>You must enter a username!</strong></p>"
        if username.lower() in ("cvs","svn"):
            return "<p><strong>CVS or SVN are reserved names!</strong></p>"
        if not password or password2!=password:
            return "<p><strong>You must enter a password, and twice the same!</strong></p>"
        if not accounttype:
            return "<p><strong>You must choose an account type!</strong></p>"
        if not re.match(USERNAME_PATTERN,username,re.IGNORECASE):
            return "<p><strong>Username must match this pattern: "+USERNAME_PATTERN + "<br />(essentially, no really weird characters... and space is allowed)</strong></p>"
        return None

    def listUsers(self):
        users=self.ApplicationCtx.storageEngine.listUsers(False)
        if users:
            def sorter(a,b):
                return cmp(a.upper(), b.upper())
            users=list(users)
            users.sort(sorter)
        return users

    def createUser(self, username, password, accounttype):
        self.write("<strong>Creating user '"+username+"'</strong>")
        userdir = os.path.join(self.WebApp.getConfigItem("storage"), username)
        
        if os.path.isdir(userdir):
            raise IOError("Userdir already exists, won't overwrite: "+userdir)
        else:
            os.makedirs(userdir)
            self.write("<br />Created user blog data dir: "+userdir)
            userfilesdir=self.WebApp.getConfigItem("files")+'/'+username
            os.mkdir(userfilesdir)
            os.chmod(userfilesdir, frog.DIRPROT)
            self.write("<br />Created user file storage dir: "+userfilesdir)
                
            storageEngine=self.ApplicationCtx.storageEngine.createNew(username)
            self.write("<br />Created id file")
        
            user=frog.objects.User(storageEngine, username, password, accounttype)
            
            user.name=username
            user.email=None
            
            if accounttype==frog.ACCOUNTTYPE_BLOGGER:
                user.displaystrings= {
                    "pagetitle": "%s's blog" % username,
                    "subtitle": "{edit profile to change this text}",
                    "menutext": "{edit profile to change this text}",
                    "footertext": '&copy; '+self.escape(username)+' - powered by Frog <a href="'+self.URLprefix+'about"><img src="'+self.URLprefix+'img/frog.gif" alt="a frog" style="vertical-align: bottom;" /></a> - valid XHTML+CSS'
                    }
                user.links={"Irmen de Jong" : "http://www.razorvine.net",
                            "About this website" : urllib.basejoin(self.Request.getBaseURL(),self.URLprefix)+"about" }
                            
                user.addNewCategory(frog.objects.DEFAULT_CATEGORY_NAME)
            
            user.store()
            
            self.write("<br />Set initial password and created user file")
            
            user2 = self.ApplicationCtx.storageEngine.loadUser(username)
            if user2.userid==user.userid and user2.password==user.password:
                self.write("<br />User verified")
            else:
                raise IOError("USER VERIFY ERROR")
               
            if accounttype==frog.ACCOUNTTYPE_BLOGGER:
    
                # User account has been created, but it's a blogger user;
                # so create the stuff that's needed for a blogger.
    
                storageEngine.createBlogDirsForToday()
                
                self.write("<br />Created article directories")
             
                catId = user2.categories.keys()[0]
                contentTxt = "Welcome! This is an example blog entry, you may want to remove it..."
                env={"urlprefix": self.URLprefix, "userid": user2.userid}
                blog=frog.objects.BlogEntry(storageEngine, user2.categories[catId], "Welcome to Frog!", frog.util.contentcleanup(contentTxt,env))
                blog.store()
                
                self.write("<br />Created sample blog entry")
                
                # update stats...
                self.WebApp.getSnakelet("articlestats.sn").updateStats(username)
    
                self.write("<br />Updated article stat cache")
                user.refreshCategories()
                self.write("<br />Updated categories cache")
                
                # read it back...
                firstdate=storageEngine.listBlogEntryDates()[0]
                firstentry=storageEngine.listBlogEntries(firstdate)[0]
                blog=frog.objects.BlogEntry.load(storageEngine,firstdate, firstentry)
                self.write("<br />Blog entry verified")
            