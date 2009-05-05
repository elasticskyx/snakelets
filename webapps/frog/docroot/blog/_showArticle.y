<%!--============================================
        utility methods to generate various
        HTML lists, article displays, etc.
===============================================--%>       
<%@import=import os, frog.util, frog%>
<%@import=from frog.text.errors import MarkupSyntaxError%>
<%def showArticleDate(date):%>
    <h3 class="date"><%=frog.util.longdatestr(date)%></h3>
<%end%>

<%!--============== ARTICLE PREVIEW ==============--%>
<%def showArticlePreview(entry):%>
    <%
    timestr = entry.datetime[1][:5]
    userURLprefix = frog.util.userURLprefix(self)
    filepath=os.path.join(self.WebApp.getConfigItem("files"), self.SessionCtx.user.userid)
    env={"urlprefix": self.URLprefix, "userid": self.SessionCtx.user.userid, "filepath":filepath, "smileys": None}
    if entry.smileys:
        env["smileys"]=self.SessionCtx.user.smileycolor
    %>
    <div class="article">
    <h4><%=self.escape(entry.title)%></h4>
<%
try:
    html=frog.util.content2html(entry.text,env)
except MarkupSyntaxError,x:
    html='<span class="error">Article formatting error: %s</span>' % x
self.write(html)

if entry.articletype=="split" and entry.text2:
    self.write('<hr /><div style="text-align: center"><em>Article is splitted. The &quot;read more...&quot; text follows below.</em></div><hr />')
    try:
        html=frog.util.content2html(entry.text2,env)
    except MarkupSyntaxError,x:
        html='<span class="error">Article formatting error: %s</span>' % x
    self.write(html)
%>
    <address>&bull; Wrote <%=self.escape(self.SessionCtx.user.userid)%> at <%=timestr%> |
    <%if entry.allowcomments:%>
     <%if self.SessionCtx.user.onlyregisteredcommenting:%>(comments allowed by registered users)
     <%else:%>(comments allowed by anybody)<%end%>
    <%else:%>
     (comments are not allowed!)
    <%end%>
    </address>
    </div>
<%end%>

<%!--============== ARTICLE (NORMAL, with or without comments) ==============--%>
<%def showArticle(entry, numcomments, withDate=True, withComments=False, preview=False):%>
    <%if withDate: showArticleDate(entry.datetime[0])%>
    <%
    timestr = entry.datetime[1][:5]
    userURLprefix = frog.util.userURLprefix(self)
    
    commentsurl, editurl = frog.util.articleURL(self,entry,True)
    
    user=self.SessionCtx.user
    filepath=os.path.join(self.WebApp.getConfigItem("files"), user.userid)
    env={"urlprefix": self.URLprefix, "userid": user.userid, "filepath":filepath, "smileys":None}
    if entry.smileys:
        env["smileys"]=user.smileycolor
    
    %>
    <div class="article">
    <h4><a href="<%=commentsurl%>" title="permalink"><img class="permalink" alt="permalink" src="<%=asset('img/permalink.png')%>" /></a>  <%=self.escape(entry.title)%></h4>
    <div class="category"><a href="<%=userURLprefix%>category/<%=entry.category%>"><%=self.escape(user.categories[entry.category].name)%></a></div>
<%
try:
    html=frog.util.content2html(entry.text,env)
except MarkupSyntaxError,x:
    html='<span class="error">Article formatting error: %s</span>' % x
self.write(html)
if entry.articletype=="split" and entry.text2:
    if withComments:
        # the full article view (with comments) includes the un-split article.
        self.write('&mdash;')
        try:
            html=frog.util.content2html(entry.text2,env)
        except MarkupSyntaxError,x:
            html='<span class="error">Article formatting error: %s</span>' % x
        self.write(html)
    else:
        # the short article view includes a "read more..." link
        self.write('&nbsp; &nbsp; &bull; <em><a href="%s">Read more &raquo;</a></em>' % commentsurl)
%>
    <address>&bull; Wrote <a href="<%=url('blog/profile')+'?u='+self.escape(user.userid)%>"><%=self.escape(user.userid)%></a> at <%=timestr%>
    <%if entry.numedits>0:%>
     (edited <%=entry.numedits%>&times;, last on <%=frog.util.mediumdatestr(entry.lastedited)%>)
    <%end%>
    <%
    if user.countreads:
        # Determine when to increment the article read count. Only increment when the article is not shown as preview,
        # and the user-agent must not be search bot. Also, the count is only increased when the article is shown
        # with comments (so a front-page view doesn't count).
        increment=not preview and withComments and not frog.util.isSpider(self.Request.getUserAgent())
        readcount=entry.countreads(increment, self.Request)
        self.write("| read %d&times; " % readcount)
    %>
    <%if withComments:%>
      <%if entry.allowcomments and (not user.onlyregisteredcommenting or self.User):%>
       | <a href="#writecomment">Add comment</a>
      <%end%>
    <%else:%>
      <%if entry.allowcomments or numcomments>0:%>
       | <a href="<%=commentsurl%>"><%=numcomments%> Comments</a>
      <%end%>
    <%end%>
    <%if self.User and self.User.hasPrivilege(frog.USERPRIV_BLOGGER):%>
     | <a href="<%=editurl%>">Edit this article</a>
    <%end%>
    </address>
    </div>
<%end%>

<%!--============== COMMENT (normal or preview) ==============--%>
<%def showComment(entry, comment, preview=False):%>
<%
filepath=os.path.join(self.WebApp.getConfigItem("files"), self.SessionCtx.user.userid)
env={"urlprefix": self.URLprefix, "userid": self.SessionCtx.user.userid, "filepath":filepath, "smileys": None }
if comment.smileys:
    env["smileys"]=user.smileycolor
%>
<a style="font-size: 1px; margin: 0px; padding: 0px;" id="c<%=comment.id%>"></a>
<%if preview:%><div class="commentPreview"><%else:%><div class="comment"><%end%>
<%
try:
    html=frog.util.content2html(comment.text,env,comment=True)
except MarkupSyntaxError,x:
    html='<span class="error">Article formatting error: %s</span>' % x
self.write(html)
%>
  <address class="comment">&bull; wrote
   <%!-- if commenting user is a registered user, show profile link --%>
   <%if comment.author[0] in self.ApplicationCtx.registeredusers:%><a href="<%=url('blog/profile')+'?u='+self.escape(comment.author[0])%>"><%=self.escape(comment.author[0])%></a>
   <%!-- if there's an url, show it --%>
   <%elif comment.author[1]:%><a href="<%=self.escape(comment.author[1])%>"><%=self.escape(comment.author[0])%></a>
   <%!-- don't show a link, show just the author name. --%>
   <%else:%><%=self.escape(comment.author[0])%>
   <%end%>
   <%!-- if there's an email address, show it IF the logged in user is the blog owner--%>
   <%if comment.author[2] and self.User and self.User.hasPrivilege(frog.USERPRIV_BLOGGER):%><a href="mailto:<%=self.escape(comment.author[2])%>"><img style="vertical-align:top" src="<%=asset('img/mailto.gif')%>" alt="mail"/></a><%end%>
   <%if comment.ipaddress:%>(<a href="javascript:alert('ip address = <%=comment.ipaddress%>')">ip</a>)
   <%end%> on <%=frog.util.mediumdatestr(comment.datetime[0])%>, <%=comment.datetime[1][:5]%>
   <%
     commentlink,editurl=frog.util.commentURL(self,entry,comment,True)
   %>
   <%if comment.id and not preview:%>
    &nbsp;<a href="<%=commentlink%>" title="permalink"><img class="permalink" alt="permalink" src="<%=asset('img/permalink.png')%>" /></a>
    <%if self.User and self.User.hasPrivilege(frog.USERPRIV_BLOGGER):%>
     | <a href="<%=editurl%>">Edit this comment</a>
    <%end%>
   <%end%> 
  </address>
  </div>
<%end%>

<%!--============== LIST OF ARTICLES ==============--%>
<%
def showArticleList(storageEngine, entries):
    prevdate=None
    for entry in entries:
        printdate=False
        if entry.datetime[0] != prevdate:
            prevdate=entry.datetime[0]
            printdate=True
        numcomments=storageEngine.getNumberOfComments(entry.datetime[0], entry.id)
        showArticle(entry,numcomments,printdate)
%>
