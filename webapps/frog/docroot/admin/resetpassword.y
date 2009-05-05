<%!--=========================================

    Reset Password page, including the logic

============================================--%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Reset Password%>
<%@pagetemplatearg=left=Help with lost/forgotten passwords%>
<%@inherit=frog.UserUtils.UserAccount%>
<%@indent=4spaces%>
<%@import=import frog.objects, frog.util%>
<%@import=import os%>
<%

self.Request.setEncoding("UTF-8")
username=self.Request.getParameter("username")
userdir = os.path.join(self.WebApp.getConfigItem("storage"), username)

action = self.Request.getParameter("action")

%>
<%!-- =================== CURRENTLY DEFINED USERS ===================== --%>
<%if not action and not username:%>
<p><strong>Currently defined users:</strong>
<br /><%
users=self.listUsers()
if users:
    self.write(", ".join(users))
else:
    self.write("<i>none.</i>")
%></p>
<br />
<%!-- =================== RESET PASSWORD FORM ===================== --%>
<p><strong>Reset Password</strong></p>
<form action="<%=self.getURL()%>" method="post" accept-charset="UTF-8">
<table>
<tr><td align="right">Username:</td><td><input type="text" name="username" size="20" maxlength="20" /></td></tr>
<tr><td align="right">New password:</td><td><input type="password" name="password" size="20" maxlength="20" /></td></tr>
<tr><td align="right">(password again):</td><td><input type="password" name="password2" size="20" maxlength="20" /></td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="hidden" name="action" value="resetpassword" /><input type="submit" value="Change" /></td></tr>
</table>
</form>
<%!-- =================== RESET PASSWORD LOGIC ===================== --%>
<%elif action=="resetpassword":%>
<%
password=self.Request.getParameter("password")
password2=self.Request.getParameter("password2")

# validate the input.
error=self.validateAccountData(username, password, password2, accounttype=True)
if error:
    self.write(error)
else:
    # input is ok, so actually reset the password.

    self.write("<p><strong>Resetting password for user '"+username+"'</strong>")

    if not os.path.isdir(userdir):
        self.write("<br />Userdir doesn't exist! Can't find: "+userdir)
        self.write("<br /><a href=\""+self.Request.getRequestURLplain()+"\">Go back</a>")
    else:
        userfilesdir=self.WebApp.getConfigItem("files")+'/'+username
        os.chmod(userfilesdir, frog.DIRPROT)

        user=self.ApplicationCtx.storageEngine.loadUser(username)
        user.password = password

        user.store()

        self.write("<br />Reset password in user file")

        user2 = self.ApplicationCtx.storageEngine.loadUser(username)
        if user2.userid==user.userid and user2.password==user.password:
            self.write("<br />User verified")
        else:
            self.abort("USER VERIFY ERROR")

        self.write("</p>")

        self.write("<br /><p>Done! The new password has been installed for '"+user.userid+"'.")


self.write("<br /><p><a href=\""+self.Request.getRequestURLplain()+"\">Reset another one</a></p>")

%>
<%else:%>
Invalid action.
<%end%>
<br />
<hr />
<a href="<%=url("admin/")%>">Back to menu</a>

