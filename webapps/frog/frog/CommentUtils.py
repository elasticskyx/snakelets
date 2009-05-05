#
#   Utilities for processing the comment editing. in the form of 
#   an Ypage base class. (The article page inherits from this class)
#

import frog.objects
import frog.util
import types
import time
import random
import os, inspect
from frog.storageerrors import StorageError

import logging
log=logging.getLogger("Snakelets.logger")

REMEMBER_COOKIE="Frog_comment_remember"

# create a new captcha generator
import frog.antispam.captcha
_basedir=os.path.dirname(inspect.getfile(frog.antispam.captcha))
_fontpath=os.path.join(_basedir, "ChildsPlay.ttf")
_bgpict=os.path.join(_basedir, "captchabg.png")
captchaGenerator=frog.antispam.captcha.CaptchaGen(_fontpath, (100,80,60), (60,40,30), textsize=32, bgpicture=_bgpict, squiggly=True, noiselines=False)


# we'll reuse prefillFormValues and prepareEditBlogEntry
import SubmitUtils  

class Comment(SubmitUtils.Submit):

    def validateCommentForm(self, form, ignoreUserName=False):
        if self.Request.getSession().isNew():
            self.abort("Session is invalid. Have (session-)cookies been disabled?")
        name=form.get("name","").strip()
        url=form.get("url","").strip()
        email=form.get("email","").strip()
        smileys=form.get("smileys","").lower()=="true"

        if self.User and not name and not url and not email:
            # if name and url are not given, take them from the currently logged in user (if any!)
            name=self.User.userid
            url=self.User.homepage
            email=self.User.email
            
        if url:
            x=url.upper()
            if not x.startswith("HTTP://") and not x.startswith("HTTPS://"):
                url="http://"+url
        text=frog.util.fixTextareaText(form.get("text"))
        if not name:
            self.RequestCtx.formErrors["name"]="required"
        elif self.SessionCtx.storageEngine.isRegisteredUser(name):
            if not ignoreUserName and ( not self.User or name!=self.User.userid ):
                self.RequestCtx.formErrors["name"]="you are not allowed to use the name of a registered user"
        if not text:
            self.RequestCtx.formErrors["text"]="required"
        elif len(text)>4000:
            self.RequestCtx.formErrors["text"]="too long (max 4000)"
        if email and not frog.util.validEmailAddr(email):
            self.RequestCtx.formErrors["email"]="invalid address"

        if hasattr(self.SessionCtx,"currentPuzzle") and self.SessionCtx.currentPuzzle and not form.get("comment-preview"):
            try:
                answer=int(form.get("puzzle",""))
                correct = eval("%d%s%d" % self.SessionCtx.currentPuzzle)
                if answer==correct:
                    # remove the puzzle
                    del self.SessionCtx.currentPuzzle
                else:
                    self.RequestCtx.formErrors["puzzle"]="your answer was wrong"
            except ValueError:
                self.RequestCtx.formErrors["puzzle"]="wrong answer, just type numbers"

        if hasattr(self.SessionCtx,"currentCaptcha") and self.SessionCtx.currentCaptcha and not form.get("comment-preview"):
            captchaError=None
            answer=form.get("captcha","")
            captcha=self.SessionCtx.currentCaptcha
            del self.SessionCtx.currentCaptcha
            if captcha.age()>60: # time out after 1 minute
                captchaError="captcha image timed out, please try again"
            elif answer.lower()!=captcha.word.lower():
                captchaError="wrong captcha answer"
            if captchaError:
                self.RequestCtx.formErrors["captcha"]=captchaError

        if self.WebApp.getConfigItem("antispam") and not form.get("comment-preview"):
            # check all fields and the comment text against the spam blacklist
            error=self.ApplicationCtx.AntiSpam.check(name)
            if error:
                self.RequestCtx.formErrors["name"]="SPAM: "+error
            error=self.ApplicationCtx.AntiSpam.check(url)
            if error:
                self.RequestCtx.formErrors["url"]="SPAM: "+error
            error=self.ApplicationCtx.AntiSpam.check(email)
            if error:
                self.RequestCtx.formErrors["email"]="SPAM: "+error
            error=self.ApplicationCtx.AntiSpam.check(text)
            if error:
                self.RequestCtx.formErrors["text"]="Your comment has been classified as SPAM: "+error
                # delay to punish spammers
                time.sleep(4)

        userid=None
        if self.User:
            userid=self.User.userid
        env={"urlprefix": self.URLprefix, "userid": userid}
        text=frog.util.contentcleanup(text,env)
        return name,url,email,text,smileys

    def cleanup(self):
        if hasattr(self.SessionCtx,"currentEntry"):
            del self.SessionCtx.currentEntry
        if hasattr(self.SessionCtx,"currentComments"):
            del self.SessionCtx.currentComments

    def process(self, user):
        self.Request.setEncoding("UTF-8")
        form=self.Request.getForm()
        self.prefillFormValues(form)
        action=form.get("action")
        
        if action:
            if form.get("remember"):
                # remember was switched on, so create a remember-me cookie
                self.setCookie(REMEMBER_COOKIE, "%s|%s|%s" % (form.get("name",""),form.get("url",""),form.get("email","")), path=self.URLprefix, maxAge=30*24*3600)   # remember for 30 days
            else:
                self.delCookie(REMEMBER_COOKIE, path=self.URLprefix)
        else:
            # no form action, prefill from remember-me cookie
            remembercookie = self.Request.getCookies().get(REMEMBER_COOKIE)
            if remembercookie:
                remembercookie = remembercookie[0]
                cookie_name, cookie_url, cookie_email = remembercookie.split('|')
                self.RequestCtx.formValues["name"] = cookie_name
                self.RequestCtx.formValues["url"] = cookie_url
                self.RequestCtx.formValues["email"] = cookie_email
                self.RequestCtx.formValues["remember"]=True
        
        self.RequestCtx.previewComment=None
        
        # check if form submission really is allowed
        if action:
            entry=self.SessionCtx.currentEntry
            if not entry.allowcomments:
                self.abort("commenting is not allowed for this entry")
            if user.onlyregisteredcommenting and not self.User:
                self.abort("commenting is only allowed for registered users")
        
        try:
            if action=="comment":
                if form.get("comment-preview") or form.get("comment-submit"):
                
                    name,url,email,text,smileys=self.validateCommentForm(form)
                    
                    if not self.RequestCtx.formErrors:
                        log.debug("no form errors")
                        if self.User:
                            ipaddr=None  # no need to store ip address of logged in user
                        else:
                            ipaddr = self.Request.getRealRemoteAddr()
                        comment = frog.objects.Comment(self.SessionCtx.storageEngine, (name,url,email), ipaddr, text, smileys)
                        if form.get("comment-preview"):
                            self.RequestCtx.previewComment=comment
                        elif form.get("comment-submit"):
                            self.submitComment(comment)
                            
                else:
                    self.cleanup()
                    self.Yhttpredirect(frog.util.userURLprefix(self))
            
            elif action=="editcomment":
                commentid=int(form.get("editcomment"))
                if not form.get("comment-cancel"):
                    comment=self.determineSelectedComment(commentid)
                    form["name"]=comment.author[0] # keep the original submitter's name
                    name,url,email,text,smileys = self.validateCommentForm(form,True)
                    comment.author=(name,url,email)
                    comment.text=text
                    comment.smileys=smileys
                        
                    if not self.RequestCtx.formErrors:
                        if form.get("comment-preview"):
                            self.RequestCtx.previewComment=comment
                        elif form.get("comment-submit"):
                            self.submitComment(comment, True) # replace!
                        elif form.get("comment-delete"):
                            self.deleteComment(comment)
                else:
                    entry=self.SessionCtx.currentEntry
                    self.cleanup()
                    self.Yhttpredirect(frog.util.articleURL(self,entry))
                        
            else:
                # no action, regular page
                pass
        except StorageError,x:
            log.error("error occurent when storing comment: "+str(x))
            self.RequestCtx.formErrors["_general"]="An error occured when saving the comment. Please try again."

    def determineSelectedComment(self, commentid):
        for c in self.SessionCtx.currentComments.comments:
            if c.id==commentid:
                return c

    def deleteComment(self, comment):
        log.debug("delete comment id="+str(comment.id))
        entry = self.SessionCtx.currentEntry
        # load the comments instead of using the cached list on the session!
        # somebody may have added something in the meantime.
        comments=frog.objects.Comments.load(self.SessionCtx.storageEngine, entry.datetime[0], entry.id)
        comments.comments.remove(comment)
        if not comments.comments:
            comments.lastedited=0   # no more comments left; reset timestamp
        comments.store()
        self.cleanup()        
        self.Request.getContext().article=entry
        self.Request.getContext().status="deletedcomment"
        self.Yredirect("statusmessage.y")
  
    def submitComment(self,comment,replace=False):
        log.debug("comment submit, replace="+str(replace))
        entry = self.SessionCtx.currentEntry
        comment.store()
        self.SessionCtx.storageEngine.lockComments(entry.id)  # unique access
        numComments=0
        try:
            # load the comments instead of using the cached list on the session!
            # somebody may have added something in the meantime.
            comments=frog.objects.Comments.load(self.SessionCtx.storageEngine, entry.datetime[0], entry.id)
            if replace:
                found=False
                for idx,c in enumerate(comments.comments):
                    if c.id==comment.id:
                        comments.comments[idx] = comment
                        found=True
                        break
                if not found:
                    raise RuntimeError("uable to find comment "+str(comment.id)+" for update")
            else:
                comments.comments.append(comment)
            comments.lastedited=int(time.time())   # update timestamp
            comments.datetime=entry.datetime  # copy datetime from entry
            comments.store()
            numComments=len(comments.comments)
            log.info("comment stored, id=%d" % comment.id)
        finally:
            self.SessionCtx.storageEngine.unlockComments(entry.id)  # unique access end.
            
        self.cleanup()

        # mail the blog owner if configured
        if self.SessionCtx.user.mailnotify:
            if hasattr(self.ApplicationCtx, "MailServer"):
                mailto=self.SessionCtx.user.email   # blog owner's email
                subj="Frog comment notification"
                body="""A new comment was posted on your Frog weblog on %s
Blog entry:
    %s
    %s
    #comments: %d
Comment details:
    timestamp=%s
    author=%s
    size=%d bytes
    direct link: %s
"""
                commenturl=self.Request.getBaseURL()+frog.util.commentURL(self, entry, comment)
                body=body % (self.Request.getServerName(), entry.datetime, entry.title, numComments,
                             comment.datetime, comment.author, len(comment.text), commenturl)
                self.ApplicationCtx.MailServer.mail(mailto,subj,body)
            else:
                log.info("No mail notification could be done because no MailServer is configured")

        # delay to avoid floods
        if not self.User:
            time.sleep(4)
        self.Request.getContext().article=entry
        self.Request.getContext().status="submittedcomment"
        self.Yredirect("statusmessage.y")

    
    def prepareEditComments(self, date, Id):
        if self.Request.getParameter("action") and hasattr(self.SessionCtx,"currentComments"):
            log.debug("getting comments from session")
            return self.SessionCtx.currentComments
        else:
            log.debug("loading comments")
            self.SessionCtx.currentComments=frog.objects.Comments.load(self.SessionCtx.storageEngine, date, Id)
            return self.SessionCtx.currentComments
            


    # make up a simple math puzzle, against spam bots
    def makePuzzle(self):
        operator = random.choice("+-*")
        numbers=["zero","one","two","three","four","five","six","seven","eight","nine",
                 "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
                 "seventeen", "eighteen", "nineteen", "twenty" ]
        if operator=='+':
            operand1,operand2 = random.randint(1,9), random.randint(1,15)
            html = "%s plus %s" % (numbers[operand1],numbers[operand2])
        elif operator=='-':
            operand1,operand2 = random.randint(6,15), random.randint(1,8)
            html = "%s minus %s" % (numbers[operand1],numbers[operand2])
        elif operator=='*':
            operand1,operand2 = random.randint(2,9), random.randint(2,9)
            html = "%s times %s" % (numbers[operand1],numbers[operand2])
        self.SessionCtx.currentPuzzle = (operand1,operator,operand2)
        return html

    def makeCaptcha(self):
        word=frog.antispam.captcha.createWord(length=6)
        captcha=captchaGenerator.generateCaptcha(word)
        self.SessionCtx.currentCaptcha = captcha
        return captcha

    def erasePuzzles(self):
        try:
            del self.SessionCtx.currentPuzzle
        except AttributeError:
            pass
        try:
            del self.SessionCtx.currentCaptcha
        except AttributeError:
            pass
