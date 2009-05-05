<%!--=========================================

 MAIN TEMPLATE for the blog users's pages.
 It requires a chosen blog user and you will get menus etc.

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

# cookiecheck cannot easily be done here because it redirects to the wrong page.
# so we have to use the javascript version....

import time
starttime=time.time()

# XXX due to a limitation in Snakelets it is not yet possible to check NICELY
#  (by inheritance or whatever) things of the templated page itself... (instead of the template)
#  As a hack, we *could* use the undocumented "templatedPage" variable:
#     if templatedPage.requiresSession() != self.SESSION_NOT_NEEDED ...
#  but we run into trouble below (where we need the users's displaystrings, and where
#  we assume that there is always a session) so we just check for the presence of a filled session:

invalidUser=not hasattr(self.SessionCtx,"user")
if not invalidUser and self.User:
    # perhaps the user object on the session is not correct. Check this.
    invalidUser=not hasattr(self.User, "displaystrings")
    if invalidUser:
        self.Request.getSession().logoutUser()
if invalidUser:
    self.write("<html><body>")
    self.write("You cannot access this page directly, go via the <a href=\""+url("user/")+"\">user selection</a>.")
    self.write("<p>You may also see this error because your session has timed out. Just visit the link above to continue.")
    self.write("</body></html>")
    self.abort()

displaystrings = self.SessionCtx.user.displaystrings
metakeywords = self.SessionCtx.user.metakeywords
metadescription = self.SessionCtx.user.metadescription

%>
<%!-- =========================== HTML HEAD ======================== --%>
<%if trueXHTML: self.write('<?xml version="1.0" encoding="utf-8"?>\n')%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <link rel="shortcut icon" href="<%=asset('img/favicon.ico')%>" />
  <title><%=self.escape(displaystrings["pagetitle"])%> | <%=self.escape( self.PageArgs.get("pagetitle", displaystrings["subtitle"]) )%></title>
<%if metakeywords:%>
  <meta name="keywords" content="<%=metakeywords%>" />
<%end%>
<%if metadescription:%>
  <meta name="description" content="<%=metadescription%>" />
<%end%>
  <script type="text/javascript" src="<%=url('setfocus.js')%>"></script>
  <script type="text/javascript" src="<%=url('cookie.js')%>"></script>
  <script type="text/javascript">
<%!-- this piece of javascript contains a bit of python code to create the url, so it cannot be put into the cookie.js file... --%>
<!--
if(getCookie("SNSESSID")==null && getCookie("SNSESSIDSHR")==null) {
  if(document.location.href.indexOf("?nocookies")<0) {
    document.location.href="<%=url('cookiecheck.y','error',{'returnpage': self.URLprefix},htmlescape=False)%>";
  }
}
-->
  </script>
  <%$include="TEMPLATE_stylesheets.y"%>  <%!-- ====== THE CSS LINKS ARE INCLUDED HERE ====== --%>
</head>
<%!-- ======================= HTML BODY (DIV "page") ===================== --%>
<%if self.PageArgs.get("nofocus",""):%><body><%else:%><body onload="setFocus();"><%end%>
<div class="page">
  <%!-- INCLUDE THE HEADER (DIV "heading") --%>
  <%$include="T_header.y"%>
  <%!-- INCLUDE THE MENU --%>
  <div class="menucolumn"><%$include="T_menu.y"%></div>
  <%!-- INCLUDE THE PAGE BODY CONTENT; DEFINED IN THE ACTUAL YPAGE --%>
  <div class="contentcolumn"><%$insertpagebody%></div>
  <%!-- FOOTER --%>
  <div class="footer"><%=displaystrings['footertext']%></div>     <%!-- NO ESCAPING to allow XHTML tags, links, etc --%>
</div>
<%!-- ============== PAGE TIMINGS (DIV "pagestatus", BELOW THE FOOTER LINE) ============== --%>
<%!-- remove this piece of code and the pagestatus div if you don't want this --%>
<%
    pagetime = (time.time()-starttime)
    requesttime= (time.time() - self.Request.server.startTimeReal)
    cputime=(time.clock() - self.Request.server.startTimeCPU)
    pagestatus="Process times: page=%0.03f request=%0.03f cpu=%0.03f" % (pagetime, requesttime, cputime)
%>
<div class="pagestatus"><%=pagestatus%></div>
</body>
</html>
