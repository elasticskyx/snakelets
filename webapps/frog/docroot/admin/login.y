<%!--============================================
    LOGIN page (for 'admin' section)
================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=admin login%>
<%@pagetemplatearg=left=Welcome, Admin.%>
<%@inherit=snakeserver.user.LoginPage%>
<%@import=import frog.util, frog%>
<%
if self.User:
    self.Request.getSession().logoutUser()
    self.User=None

self.Request.setEncoding("UTF-8")    

# use the standard Snakelets login-page mechanism
self.attemptLogin( "index.y" ) 

# If the login succeeded, we are forwarded to the target page.
# If we're still here, the login failed..
error=''
if self.Request.getParameter("login"):
    error="Invalid login"
%>

<%!--=========================== LOGIN FORM ===================--%>
<form action="<%=self.getURL()%>" method="post" accept-charset="UTF-8">
<table border="0" cellspacing="10" cellpadding="1" summary="Login form">
  <tr>
    <td align="right">Name</td>
    <td><input type="text" name="login" /></td>
  </tr>
  <tr>
    <td align="right">Password</td>
    <td><input type="password" size="21" maxlength="20" name="password" /></td>
  </tr>
  <tr>
    <td />
    <td><input type="submit" value="Log in" /></td>
  </tr>
  <tr>
    <td />
    <td><strong><%=error%></strong>&nbsp;</td>
  </tr>
</table>
</form>
