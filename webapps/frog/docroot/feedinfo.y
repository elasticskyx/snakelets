<%!--==================================
    RSS feeds information
=====================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=RSS feeds%>
<%@import=import frog%>
<%
user=self.SessionCtx.user

if user.accounttype!=frog.ACCOUNTTYPE_BLOGGER:
	self.abort("only a blogger user account has rss feeds")

feedURL=self.Request.getBaseURL()+url("feeds/%s/feed.rss" % self.escape(user.userid))
%>
<h2>RSS feeds</h2>
<p>To stay current with new articles and changes on this blog,
you can subscribe to the RSS 2.0 newsfeed.</p>
<p><img src="<%=asset('img/rss.png')%>" alt="rss" /> <a href="<%=feedURL%>">Frontpage RSS feed (all categories)</a></p>
<p>There's also a separate feed for each category:</p>
<p>
<%
sortedcat=self.SessionCtx.user.categories.values()
sortedcat.sort()
for cat in sortedcat:
    self.write('<img src="'+asset('img/rss.png')+'" alt="rss" /> <a href="'+feedURL+'?cat='+str(cat.id)+'">'+cat.name+'</a><br/>')
%>
</p>
