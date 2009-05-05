<%!--=======================================
    SEARCH for articles,
    show the search result list.
==========================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Search article%>
<%@import=import frog.util%>
<%@inherit=frog.SearchUtils.Search%>
<%

self.process()  # process form contents
formErrors=self.RequestCtx.formErrors
formValues=self.RequestCtx.formValues

%>
<%$include="_categoryselectbox.y"%>

<%!--==================== SEARCH CRITERIA FORM ===============--%>
<h3>Search for an article</h3>
<h4>Find articles...</h4>
<form action="<%=self.getURL()%>" method="post" accept-charset="UTF-8">
<table border="0" cellspacing="10" cellpadding="1" summary="Article search form">
  <tr>
    <td align="right">Where title contains</td>
    <td><input type="text" name="title" value="<%=formValues.get("title","")%>" /></td>
  </tr>
  <tr>
    <td align="right">Where text contains</td>
    <td><input type="text" name="text" value="<%=formValues.get("text","")%>" /></td>
  </tr>
  <tr>
    <td align="right">In category</td>
    <td><%createCategorySelectbox("category",formValues.get("category"),self.SessionCtx.user)%></td>
  </tr>
  <tr>
    <td align="right" valign="top">Between</td>
    <td><input type="text" name="fromdate" size="10" maxlength="10" value="<%=formValues.get("fromdate","")%>" /> 
        and <input type="text" name="todate" size="10" maxlength="10" value="<%=formValues.get("todate","")%>"  /> (YYYY-MM-DD)
    <%if "dates" in formErrors:%><br /><span class="error"><%=formErrors["dates"]%></span><%end%></td>
  </tr>
  <tr>
    <td />
    <td><input type="submit" name="action" value="Search" /></td>
  </tr>
</table>
</form>

<%!--==================== SEARCH RESULT LIST ===============--%>

<%if hasattr(self.RequestCtx,"searchResult"):%>
    <%if len(self.RequestCtx.searchResult)==0:%>
        <p><span class="message">No matching articles found.</span></p>
    <%else:%>
        <table class="overview">
        <tr><td></td><td colspan="3"><span class="message"><%=len(self.RequestCtx.searchResult)%> articles found!</span></td></tr>
        <tr><th></th><th>Category &nbsp; </th><th>Date</th><th>Title</th></tr>
        <%for article in self.RequestCtx.searchResult:%>
         <tr>
          <td><a href="<%=frog.util.articleURL(self,article)%>" title="go to the article"><img class="permalink" alt="link" src="<%=asset('img/permalink.png')%>" /></a></td>
          <td><%=self.escape(self.SessionCtx.user.categories[article.category].name)%></td>
          <td><%=article.datetime[0]%> @ <%=article.datetime[1]%></td>
          <td class="longtext"><%=self.escape(article.title)%></td>
         </tr>
        <%end%>
        </table>
        <p><span class="count">Click the article icon <img alt="link" src="<%=asset('img/permalink.png')%>" /> to open the article.</span></p>
    <%end%>
<%end%>
<%if self.RequestCtx.formMessage:%>
<p><span class="message"><%=self.RequestCtx.formMessage%></span></p>
<%end%>

