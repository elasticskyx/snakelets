<%!--=========================================

 Entrance to the admin pages.
 First checks if cookies are enabled, then redirects to the admin index page.

============================================--%>
<%$include="cookiecheck.y"%>
<%
checkCookies()
self.Yhttpredirect("admin/")
%>
