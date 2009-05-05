<%!--============================================================
    Show POPULAR articles
    (articles with most views, and with most comments)
===============================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Popular articles%>
<%@import=import frog.util%>
<%@import=from frog.storageerrors import StorageError%>
<%@import=import time%>
<%

popular_views, popular_comments=self.SessionCtx.storageEngine.listPopularArticles()

%>
<h2>Popular articles</h2>
<br />
<table class="overview">
<caption>Most viewed</caption>
<%if popular_views:%>    
    <tr><th></th><th>Viewed</th><th>Cmts</th><th>Created</th><th>Category</th><th>Title</th></tr>
    <%for numviews, numcomments, date, articleId in popular_views:%>
      <%
      try:
        article=frog.objects.BlogEntry.load(self.SessionCtx.storageEngine,date,articleId)
      except StorageError:
        article=None%>
      <%if article:%>
      <tr>
       <td><a href="<%=frog.util.articleURL(self,article)%>" title="go to the article"><img class="permalink" alt="link" src="<%=asset('img/permalink.png')%>" /></a></td>
       <td style="text-align: center"><%=numviews%></td>
       <td style="text-align: center"><%=numcomments%></td>
       <td><%=article.datetime[0]%></td>
       <td><%=self.escape(self.SessionCtx.user.categories[article.category].name)%></td>
       <td class="longtext"><%=self.escape(article.title)%></td>
      </tr>
      <%end%>
    <%end%>
<%else:%>
    <tr><td>The required data is not yet available</td></tr>
<%end%>    
</table>
<br />
<%!-- ********************** COUNTING THE COMMENTS IS VERY SLOW NOW (NOT CACHED) *****************
<table class="overview">
<caption>Most comments</caption>
<%if popular_comments:%>
    <tr><th></th><th>Comments</th><th>Created</th><th>Category</th><th>Title</th></tr>
    <%for numcomments, date, articleId in popular_views:%>
      <%article=frog.objects.BlogEntry.load(self.SessionCtx.storageEngine,date,articleId)%>
      <tr>
       <td><a href="<%=frog.util.articleURL(self,article)%>" title="go to the article"><img class="permalink" alt="link" src="<%=asset('img/permalink.png')%>" /></a></td>
       <td style="text-align: center"><%=numcomments%></td>
       <td><%=article.datetime[0]%></td>
       <td><%=self.escape(self.SessionCtx.user.categories[article.category].name)%></td>
       <td class="longtext"><%=self.escape(article.title)%></td>
      </tr>
    <%end%>
<%else:%>
    <tr><td>The required data is not yet available</td></tr>
<%end%>    
</table>
******************************************* --%>

<p><span class="count">Click the article icon <img alt="link" src="<%=asset('img/permalink.png')%>" /> to open the article.</span></p>


