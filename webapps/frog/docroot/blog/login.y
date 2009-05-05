<%!--============================================
    LOGIN page.
    (for 'login' users but also blogger users)
================================================--%>
<%@session=yes%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=user login%>
<%@pagetemplatearg=left=Welcome.%>
<%@inherit=snakeserver.user.LoginPage, frog.LoginUtils.CookieLogin%>
<%@import=import frog.util, frog%>
<%
if self.User:
    self.Request.getSession().logoutUser()
    self.User=None

if not hasattr(self.SessionCtx,"user"):
    self.abort("You cannot log in using this page, go via the <a href=\""+self.URLprefix+"user/\">user selection</a>. If (session-)cookies are disabled you'll also see this message.")

userURLprefix=frog.util.userURLprefix(self)

self.Request.setEncoding("UTF-8")    

def loginSuccesful(user):
    # login was successful, but we have to check for privileges.
    # if the logged in user is the same as the user of the current weblog,
    # the logged in user gets "blogger" privileges, and filemgr access too
    if user.userid == self.SessionCtx.user.userid:
        user.privileges.add(frog.USERPRIV_BLOGGER)
        user.privileges.add(frog.USERPRIV_FILEMGR)
    if self.Request.getParameter("remember"):
        # remember the user by setting a login-cookie
        self.sendLoginRememberCookie(self.Request.getParameter("login"), self.Request.getParameter("password") )

# check for & process a login Cookie
self.processLoginRememberCookie()

# use the standard Snakelets login-page mechanism
self.attemptLogin( userURLprefix, loginSuccesful ) 

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
    <td><input type="text" name="login" value="<%=self.escape(self.SessionCtx.user.userid)%>" /></td>
  </tr>
  <tr>
    <td align="right">Password</td>
    <td><input type="password" size="21" maxlength="20" name="password" /></td>
  </tr>
  <tr>
    <td></td>
    <td><input type="checkbox" name="remember" id="c1"/><label for="c1">Remember me</label></td>
  </tr>
  <tr>
    <td />
    <td><input type="submit" value="Log in" /> &nbsp; <span class="error"><%=error%></span></td>
  </tr>
  <tr>
    <td />
    <td><a href="<%=url('forgotpw')%>">Forgot password? </a></td>
  </tr>
</table>
</form>
