<%!--==================================
    Show the user profile data.
=====================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=User profile%>
<%@import=from frog.storageerrors import StorageError%>
<%@import=import frog.util, frog%>
<%
userid=self.Request.getParameter("u")
if userid:
    try:
        user=self.SessionCtx.storageEngine.loadUser(userid)
    except StorageError,x:
        self.abort("requested user profile could not be loaded")
else:
    user=self.SessionCtx.user

version=None
if hasattr(user,"version"):
    version=user.version
    
%>
<h3>User Profile</h3>
<table cellspacing="10">
<tr>
  <td align="right">User id:</td><td><strong><%=self.escape(user.userid)%></strong></td>
</tr>
<tr>
  <td align="right">Full name:</td><td><%=self.escape(user.name) or '<i>not specified</i>'%></td></tr>
<tr>
  <td align="right">E-mail:</td><td><%=self.escape(user.email) or '<i>not specified</i>'%></td></tr>
<tr>
  <td align="right">Homepage:</td>
  <td>
  <%if user.homepage:%><a href="<%=self.escape(user.homepage)%>"><%=self.escape(user.homepage)%></a>
  <%else:%><i>not specified</i><%end%>
  </td>
</tr>
<%if user.accounttype==frog.ACCOUNTTYPE_BLOGGER:%>
<tr>
<td align="right">Frog:</td>
<td><a href="<%=frog.util.userURLprefix(self,user.userid)%>"><%=self.escape(user.userid)%>'s blog site</td>
</tr>
<%end%>
</table>
