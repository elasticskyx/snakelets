<%!--==============================================
    Shows recent articles in a chosen category.
=================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@import=import frog.util, frog%>
<%@import=import frog.objects%>
<%@import=from frog.storageerrors import StorageError%>
<%@method=templateArgs(self, request):
    categoryId = self.Request.getParameter("category")
    if categoryId:
        categoryName=self.SessionCtx.user.categories[int(categoryId)].name
        return {"pagetitle": "Category: "+categoryName }
    return {}
%>
<%
user=self.SessionCtx.user
storageEngine=self.SessionCtx.storageEngine

categoryId = int(self.Request.getParameter("category"))
categoryName=user.categories[categoryId].name

import logging
log=logging.getLogger("Snakelets.logger")


def readArticlesFromDateInCategory(date, categoryId):
    # XXX this implementation is slow: it reads every article for that date and checks the category... 
    entryids=storageEngine.listBlogEntries(date)
    entryids.reverse() # descending
    try:
        all = [ frog.objects.BlogEntry.load(storageEngine, date, Id) for Id in entryids ]
        return [ article for article in all if article.category==categoryId ]
    except StorageError,x:
        log.error("Error loading articles: "+str(x))
        self.abort("cannot load articles")


dates=storageEngine.listBlogEntryDates()
entries=[]
if dates:
    SHOWAMOUNT=10       # show 10 articles at most
    
    for showdate in dates:
        articles = [entry for entry in readArticlesFromDateInCategory(showdate,categoryId) ]
        entries.extend(articles)
        if len(entries)>=SHOWAMOUNT:
            break

%>
<h2>Recent articles in '<%=self.escape(categoryName)%>'</h2>
<%$include="_showArticle.y"%>
<%
if dates and entries:
    showArticleList(storageEngine, entries)

    self.write("<hr/><em>%d shown; more articles may be found in the archives." % len(entries) )
    self.write(' The <img alt="permalink" src="'+url("img/permalink.png")+'" /> icon is the article\'s permalink.</em>')
else:%>
  <%if self.User and self.User.hasPrivilege(frog.USERPRIV_BLOGGER):%>
  <h4>You have not written anything yet.</h4>
  <p>Choose <i>submit</i> to write an article.</p>
  <%else:%>
  <h4>There are no articles yet.</h4>
  <%end%>
<%end%>

