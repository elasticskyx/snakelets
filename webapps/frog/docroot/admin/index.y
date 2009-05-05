<%!--======================================
        Admin index page (menu).
=========================================--%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Admin Pages%>
<%@pagetemplatearg=left=Make a choice%>
<%@authmethod=loginpage;admin/login.y%>
<%
if self.Request.getParameter("logout"):
    self.Request.deleteSession()
    self.User=None
    self.Yhttpredirect(self.URLprefix)  # if logging out, redirect back to webapp begin

%>
<h4>Hello, <%=self.escape(self.User.name)%>!</h4>
<ul>
<li><a href="createuser.y">Create user accounts</a></li>
<li><a href="resetpassword.y">Reset passwords</a></li>
<li><a href="convert.y">Convert blog data from older version</a></li>
<li><a href="index.y?logout=yes">Log out</a></li>
</ul>
