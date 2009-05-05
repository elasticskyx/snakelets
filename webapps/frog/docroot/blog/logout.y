<%!--===============================
       LOGOUT page
    (logs out & removes session)
================================--%>
<%@session=yes%>
<%@import=import frog.util%>
<%
self.Request.getSession().logoutUser()
self.User=None

if not hasattr(self.SessionCtx,"user"):
    self.abort("You cannot access this page directly, go via the <a href=\""+self.URLprefix+"user/\">user selection</a>.")

userURLprefix=frog.util.userURLprefix(self)

self.Yhttpredirect( userURLprefix )
%>
