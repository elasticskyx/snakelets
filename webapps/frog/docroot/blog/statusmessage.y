<%!--===========================================
    Shows a simple status/confirmation message,
    after some action has been performed.
===============================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=nofocus=True%>
<%@import=import frog.util%>
<%
status=self.Request.getParameter("status")
entry=self.Request.getParameter("article")
%>
<%if status=="submitted":%>
<h2>Article submitted</h2>
<p />
<p>Your article has been submitted.</p>
<p>(It may take a short while until it shows up)</p>
<p><a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></p>
<%elif status=="submittedcomment":%>
<h2>Article comment submitted</h2>
<p />
<p>Your comment has been submitted.</p>
<p><a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></p>
<%elif status=="deletedcomment":%>
<h2>Article comment deleted</h2>
<p />
<p>The comment has been deleted.</p>
<p><a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></p>
<%elif status=="deleted":%>
<h2>Article deleted</h2>
<p />
<p>This article has been deleted:</p>
<p>title: <%=self.escape(entry.title)%>
<br />date: <%=entry.datetime[0]%>  <%=entry.datetime[1]%>
<br />category: <%=self.escape(self.SessionCtx.user.categories[entry.category].name)%>
</p>
<p>(It may take a short while until this is shown)</p>
<%elif status=="cannotdelete":%>
<h2>Article not deleted</h2>
<p />
<p>The article cannot be deleted, usually because there are comments to the article.</p>
<p><a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></p>
<br />
<br />
<p><em>Warning! The following cannot be undone!</em></p>
<form method="POST" action="<%=url('blog/submit?edit')%>">
<input type="hidden" name="action" value="submit" />
<input type="submit" name="delete-article-and-all-comments" value="Delete ALL comments, then the article" style="color: red" />
</form>
<%else:%>
<p>Unknown status: <%=status%></p>
<p><a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></p>
<%end%>
