<%!--=========================================

 INCLUSIONG TEMPLATE for the LEFT MENU.
 (included from the main template page)
 displaystrings is set by the template itself.

============================================--%>
<%@inputencoding="ISO-8859-15"%>
<%@import=import frog.util%>
<%@import=import calendar,time%>
<%
userURLprefix=frog.util.userURLprefix(self)
%>
<div class="vnav">
<%!-- ====== NAVIGATION SECTION ====== --%>
<div class="navigation">
  <span class="title">Navigation</span>
<ul>
  <li><a href="<%=userURLprefix%>">home</a></li>
<%if self.SessionCtx.user.customfrontpage:%>
  <li><a href="<%=userURLprefix%>?articles">articles</a></li>
<%end%>
  <li><a href="<%=userURLprefix%>?today">today's</a></li>
  <li><a href="<%=userURLprefix%>?active">active</a></li>
  <li><a href="<%=userURLprefix%>?popular">popular</a></li>
  <li><a href="<%=self.URLprefix%>blog/profile.y?u=<%=self.escape(self.SessionCtx.user.userid)%>">userprofile</a></li>
<%if self.SessionCtx.user.rssenabled:%>
  <li><a href="<%=url('feedinfo')%>">RSS feeds</a></li>
<%end%>
</ul>
</div>
<%!-- ====== CATEGORIES SECTION ====== --%>
<div class="categories">
  <span class="title">Categories</span>
<ul>
<%
sortedcat= self.SessionCtx.user.categories.values()
sortedcat.sort()
for cat in sortedcat:%>
  <li><a href="<%=userURLprefix%>category/<%=cat.id%>"><%=self.escape(cat.name)%></a><span class="count"><%=cat.count%></span></li>
<%end%>
</ul>
</div>
<%!-- ====== ARCHIVE SECTION ====== --%>
<div class="archive">
  <span class="title">Older articles</span>
<ul>
<%
curmonth = time.localtime().tm_mon
curyear = time.localtime().tm_year

storageEngine=self.SessionCtx.storageEngine

months=[]
for i in range(self.WebApp.getConfigItem("archivemenu_nummonths")):
    if curmonth<=0:
        curmonth+=12
        curyear-=1
    articleCount, articlesInMonth = storageEngine.listArticlesInMonth(curyear, curmonth)
    months.append( (curyear, curmonth, calendar.month_abbr[curmonth], articleCount ) )
    curmonth-=1

for year, month, monthname, count in months:%>
    <li><a href="<%=userURLprefix%>archive/<%='%d-%d'%(year,month)%>"><%=monthname%></a><span class="count"><%=count%></span></li>
<%end%>        
  <li><a href="<%=userURLprefix%>archive/">older&hellip;</a></li>
</ul>
</div>
<%!-- ====== LINKS SECTION ====== --%>
<div class="links">
  <span class="title">Links</span>
<ul>
<%if self.SessionCtx.user.homepage:%>
  <li><a href="<%=self.escape(self.SessionCtx.user.homepage)%>">homepage</a></li>
<%end%>     
<%
links=self.SessionCtx.user.links.items()
def linkssorter(a,b):
    return cmp(a[0].upper(), b[0].upper())
links.sort(linkssorter)
for name,url in links:%>
  <li><a href="<%=self.escape(url)%>"><%=self.escape(name)%></a></li>
<%end%> 
</ul>
</div>
</div>
<%!-- ====== MENU TEXT (XHTML) ====== --%>
<p><%=displaystrings['menutext']%></p>

