<%!--=========================================

 TEMPLATE for the pages that are not part of a blog users's site,
 so that they don't require a chosen user, don't get a menu, etc.
 (f.ex. the "about" page, or the "login" page).

============================================--%>
<%@inputencoding="iso-8859-1"%>
<%
# Contenttype header selector
# For XHTML the "best" would be to send "application/xhtml+xml" to conforming browsers,
# such as Opera and Firefox (they send that in their Accept: header). 
# However it causes Firefox to use a true XML parser to render the page,
# and that results in very strange errors when the page xhtml is not correct due to errors... :(
# So for the time being, we serve the XHTML 1.0 page as "text/html"...
# 
# accept=self.Request.getHeader("Accept") or ""
# if "application/xhtml+xml" in accept:
#     self.setContentType("application/xhtml+xml")
#     trueXHTML=True
# else:
#     self.setContentType("text/html")
#     trueXHTML=False
#
trueXHTML=False
%>
<%if trueXHTML: self.write('<?xml version="1.0" encoding="utf-8"?>\n')%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <link rel="shortcut icon" href="<%=asset('img/favicon.ico')%>" />
  <%$include="TEMPLATE_stylesheets.y"%>
  <title>Frog - <%=self.PageArgs["title"]%></title>
  <script type="text/javascript" src="<%=url('setfocus.js')%>"></script>
</head>
<%if self.PageArgs.get("nofocus",""):%><body><%else:%><body onload="setFocus();"><%end%>
<div class="page">
  <div class="heading"><h1>Frog</h1><%=self.PageArgs["title"]%></div>
  <div class="menucolumn"><%=self.PageArgs["left"]%></div>
  <div class="contentcolumn"><%$insertpagebody%></div>
  <div class="footer">powered by Frog <img src="<%=asset('img/frog.gif')%>" alt="a frog" style="vertical-align: bottom;" /> - valid XHTML+CSS</div>
</div>
</body>
</html>
