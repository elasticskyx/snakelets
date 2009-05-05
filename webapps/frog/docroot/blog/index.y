<%!--===================================================
    BLOG index page: show recent articles,
    today's articles, or articles of a specific date.
    
    However, if the user has a customfrontpage,
    it includes frontpage/<userid>.y and returns.
    (only if no page arg is given)
========================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@import=import frog.util, frog%>
<%@import=import frog.objects%>
<%@import=from frog.storageerrors import StorageError%>
<%@method=templateArgs(self, request):
    arg=self.Request.getArg()
    if arg=="today":
        return {"pagetitle":"Today's articles"}
    elif arg=="date":
        showdate = request.getParameter("date")
        return {"pagetitle":"Articles written on "+frog.util.mediumdatestr(showdate)}
    else:
        return {}
%>
<%

import logging
log=logging.getLogger("Snakelets.logger")


user=self.SessionCtx.user
storageEngine=self.SessionCtx.storageEngine


if user.customfrontpage and not self.Request.getArg():
    frontpage=url("frontpage/")+self.escape(user.userid)+".y"
    self.Ycall(frontpage)   # include the custom front page instead.
    return

def readArticlesFromDate(date, count=None):
    entryids=storageEngine.listBlogEntries(date)
    entryids.reverse() # descending
    if count:
        entryids=entryids[:count]
    try:
        return [ frog.objects.BlogEntry.load(storageEngine, date, Id) for Id in entryids ]
    except StorageError,x:
        log.error("Error loading articles: "+str(x))
        self.abort("cannot load articles")
    
showdate = None
    
arg=self.Request.getArg()
if arg=="today":
    #-------------------- TODAY'S ARTICLES
    self.write("<h2>Today's articles</h2>")
    showdate = frog.util.isodatestr() 
    entries = readArticlesFromDate(showdate)
elif arg=="active":
    #-------------------- ACTIVE ARTICLES redirect
    self.Yredirect("active.y")
elif arg=="popular":
    #-------------------- POPULAR ARTICLES redirect
    self.Yredirect("popular.y")
elif arg=="login":
    #-------------------- LOGIN PAGE redirect
    self.Yredirect("login.y")
elif arg=="date":
    #-------------------- ARTICLES OF A SPECIFIC DATE
    showdate = self.Request.getParameter("date")
    self.write("<h2>Articles written on %s</h2>"% frog.util.mediumdatestr(showdate))
    entries = readArticlesFromDate(showdate)
else:
    #-------------------- RECENT ARTICLES
    self.write("<h2>Recent articles</h2>")
    dates=storageEngine.listBlogEntryDates()
    if dates:
        entries=[]
        SHOWAMOUNT=10
        for showdate in dates:
            entries.extend( readArticlesFromDate(showdate, SHOWAMOUNT-len(entries)) )
            if len(entries)>=SHOWAMOUNT:
                break
                
%>
<%!--=================== ARTICLE LISTING ===================--%>
<%$include="_showArticle.y"%>
<%
if showdate and entries:
    showArticleList(storageEngine, entries)

    self.write("<hr/><em>%d shown; more articles may be found in the archives." % len(entries))
    self.write(' The <img alt="permalink" src="'+url("img/permalink.png")+'" /> icon is the article\'s permalink.</em>')
else:%>
  <%if self.User and self.User.hasPrivilege(frog.USERPRIV_BLOGGER):%>
  <h4>You have not written anything yet.</h4>
  <p>Choose <i>submit</i> to write an article.</p>
  <%else:%>
  <h4>There are no articles yet.</h4>
  <%end%>
<%end%>
