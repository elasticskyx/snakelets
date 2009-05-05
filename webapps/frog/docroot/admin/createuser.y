<%!--=========================================

    Account Creation page, including the logic

============================================--%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Create User%>
<%@pagetemplatearg=left=A new user%>
<%@inherit=frog.UserUtils.UserAccount%>
<%@indent=4spaces%>
<%@import=import frog%>
<%@import=import os%>
<%

self.Request.setEncoding("UTF-8")
username=self.Request.getParameter("username")

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
<%!-- =================== CREATE NEW ACCOUNT FORM ===================== --%>
<p><strong>Create new user account</strong></p>
<form action="<%=self.getURL()%>" method="post" accept-charset="UTF-8">
<table>
<tr><td align="right">Username:</td><td><input type="text" name="username" size="20" maxlength="20" /></td></tr>
<tr><td align="right">Initial password:</td><td><input type="password" name="password" size="20" maxlength="20" /></td></tr>
<tr><td align="right">(password again):</td><td><input type="password" name="password2" size="20" maxlength="20" /></td></tr>
<tr><td></td><td><input type="radio" name="account" value="<%=frog.ACCOUNTTYPE_BLOGGER%>" id="r1"/><label for="r1">Setup blog account for this user</label></td></tr>
<tr><td></td><td><input type="radio" name="account" value="<%=frog.ACCOUNTTYPE_LOGIN%>" id="r2"/><label for="r2">User is only a log-in user</label></td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td></td><td><input type="hidden" name="action" value="createuser" /><input type="submit" value="Create" /></td></tr>
</table>
</form>
<%!-- =================== CREATE NEW ACCOUNT LOGIC ===================== --%>
<%elif action=="createuser":%>
<%
password=self.Request.getParameter("password")
password2=self.Request.getParameter("password2")
accounttype=self.Request.getParameter("account")

# validate the input.
error=self.validateAccountData(username, password, password2, accounttype)
if error:
    self.write(error)
else:
    # input is ok, so actually create the new user.

    self.write("<p>")
    try:
        self.createUser(username, password, accounttype)
    except Exception,x:
        self.abort(str(x))
    else:                    
        self.write("</p>")
        self.write("<br /><p>Done! A happy welcome to '"+username+"'.")
        self.write("<br /><em>It may take a short while before the new user appears in the list.</em>")
        self.write("<br /><em>NOTE: the user's name, email, homepage etc are still blank!</em>")
        
        if accounttype==frog.ACCOUNTTYPE_BLOGGER:
            self.write("<br />The user must configure the rest of her account when logging in.</p>")

self.write("<br /><p><a href=\""+self.Request.getRequestURLplain()+"\">Add another one</a></p>")

%>
<%else:%>
Invalid action.
<%end%>
<br />
<hr />
<a href="<%=url("admin/")%>">Back to menu</a>

