<%!--============================================================
    Show ACTIVE articles
    (recently added/modified, or recently gotten a new comment)
===============================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Active articles%>
<%@import=import frog.util%>
<%@import=import time%>
<%

active=self.SessionCtx.storageEngine.listActiveArticles()

%>
<h2>Active articles (recently added, modified, or commented on)</h2>
<p>This list shows the most recently edited articles or articles that somebody commented on.</p>
<br />
<table class="overview">
<tr><th></th><th>Modified</th><th>Created</th><th>Cmts</th><th>Category</th><th>Title</th></tr>
<%for mtime, numcomments, date, articleId in active:%>
  <%article=frog.objects.BlogEntry.load(self.SessionCtx.storageEngine,date,articleId)%>
  <tr>
   <td><a href="<%=frog.util.articleURL(self,article)%>" title="go to the article"><img class="permalink" alt="link" src="<%=asset('img/permalink.png')%>" /></a></td>
   <td><%=frog.util.isodatestr(time.localtime(mtime))%> @ <%=frog.util.isotimestr(time.localtime(mtime))%></td>
   <td><%=article.datetime[0]%></td>
   <td style="text-align: center"><%=numcomments%></td>
   <td><%=self.escape(self.SessionCtx.user.categories[article.category].name)%></td>
   <td class="longtext"><%=self.escape(article.title)%></td>
  </tr>
<%end%>
</table>
<p><span class="count">Click the article icon <img alt="link" src="<%=asset('img/permalink.png')%>" /> to open the article.</span></p>


