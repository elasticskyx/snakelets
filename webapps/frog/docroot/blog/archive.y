<%@inputencoding="ISO-8859-1"%>
<%@indent=4spaces%>
<%@pagetemplate=TEMPLATE.y%>
<%@import=import frog.util%>
<%@import=import time,calendar%>
<%!--=====================================================

    This page shows a little calendar for a specific month, with navigation
    arrows to scroll backwards or forewards in time.
    Every day on which an article has been written will be a hyperlink
    that takes you to the articles of that day.
    
    The page expects a request/ctx parameter "archive" that will either be
    a string composed of YYYY-MM (the month to show), or "OLDER", which
    is a shortcut to the first month in the past that is no longer directly
    accessible as link in the archive menu.

=======================================================--%>
<%@method=templateArgs(self, request):
    archive = self.Request.getParameter("archive")
    if archive=="OLDER":
        pagetitle="Old articles"
    else:
        year, month = map(int, archive.split('-'))
        pagetitle="Articles from %s %d" % (calendar.month_name[month], year)
    return {"pagetitle": pagetitle }
%>
<%

user=self.SessionCtx.user
storageEngine=self.SessionCtx.storageEngine
now = time.localtime()


archive = self.Request.getParameter("archive")

if archive!="OLDER":
    year, month = map(int, archive.split('-'))
else:
    year,month=now.tm_year,now.tm_mon
    month-=self.WebApp.getConfigItem("archivemenu_nummonths")
    if month<=0:
        month+=12
        year-=1

year_older=year
month_older=month-1
if month_older<=0:
    month_older+=12
    year_older-=1
year_later=year
month_later=month+1
if month_later>12:
    month_later-=12
    year_later+=1

if (year_later, month_later) > (now.tm_year, now.tm_mon):
    year_later=month_later=0   # don't show the future

articleCount, articlesInMonth = storageEngine.listArticlesInMonth(year, month)
    
%>
<h2>Viewing articles from <%=calendar.month_name[month]%> <%=year%></h2>
<br />
<%!--=========== CALENDAR NAV =============--%>
<table class="calendar">
<tr><th colspan="7" style="text-align: center">
<a href="<%=year_older%>-<%=month_older%>">&lt;&lt;</a>
&nbsp; <%=calendar.month_abbr[month]%> <%=year%> &nbsp;
<%if year_later:%><a href="<%=year_later%>-<%=month_later%>">&gt;&gt;</a><%end%>
</th></tr>
<%
monthcal=calendar.monthcalendar(year,month)

articles=[]

%>
<tr>
<%!--=========== DAY NAMES =============--%>
<%for day in calendar.day_abbr:%><td><%=day%></td><%end%>
</tr>
<%!--=========== CALENDAR FIELDS =============--%>
<%for row in monthcal:%>
 <tr>
<%for day in row:
    if day:    
        if day in articlesInMonth:
            num=len(articlesInMonth[day])
            ref=frog.util.archivedArticleURL(self,year,month,day,articlesInMonth[day])
            self.write("<td><a href=\""+ref+"\" title=\"%d articles\">%d</a></td>"%(num,day))
            date="%04d-%02d-%02d" % (year,month,day)
            articles.append( (date,articlesInMonth[day]) )
        else:
            self.write("<td>%d</td>"%day)
    else:
        self.write("<td />")
self.write("\n")
%>
 </tr>
<%end%>
</table>
<br />
<p><em>There are <%=articleCount%> articles in this month.</em></p>
<%!--======== LIST OF ARTICLES IN THIS MONTH (if selected) =======--%>
<%if articles and self.Request.getParameter("viewlist"):%>
  <br />
  <table class="overview">
  <tr><th></th><th>Category &nbsp; </th><th>Date</th><th>Title</th></tr>
<%
for date,articleIds in articles:
    for articleId in articleIds:%>
      <%article=frog.objects.BlogEntry.load(storageEngine,date,articleId)%>
      <tr>
       <td><a href="<%=frog.util.articleURL(self,article)%>" title="go to the article"><img class="permalink" alt="link" src="<%=asset('img/permalink.png')%>" /></a></td>
       <td><%=self.escape(user.categories[article.category].name)%></td>
       <td><%=article.datetime[0]%> @ <%=article.datetime[1]%></td>
       <td class="longtext"><%=self.escape(article.title)%></td>
      </tr>
    <%end%>
  </table>
  <p><span class="count">Click the article icon <img alt="link" src="<%=asset('img/permalink.png')%>" /> to open the article.</span></p>
<%end%>
<%if articles and not self.Request.getParameter("viewlist"):%>
   <p><a href="?viewlist=true">View a list</a></p>
<%end%>

