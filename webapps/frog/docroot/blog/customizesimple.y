<%!--====================================
    Frog Customization forms.
=======================================--%>
<%@inputencoding="iso-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@inherit=frog.CustomizeUtils.Customize%>
<%@indent=4spaces%>
<%@session=user%>
<%

self.process()      # process the forms

# user=self.SessionCtx.user
user=self.User

formErrors = self.RequestCtx.formErrors
displaystrings=user.displaystrings

%>
<h3>Change your account settings</h3>
<%if self.RequestCtx.formMessage:%>
<p><span class="message">&bull; <%=self.RequestCtx.formMessage%></span></p>
<%end%>  
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error: <%=formErrors["_general"]%></span>
<%end%>

<%!--================== PERSONAL INFORMATION =================--%>
  <form method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
  <h4>Account data of user '<%=self.escape(user.userid)%>'</h4>
  <table border="0" cellpadding="1" cellspacing="4">
	<tr>
	  <td align="right">Login name </td>
	  <td><strong><%=self.escape(user.userid)%></strong></td>
	</tr>
	<tr>
	  <td align="right">Full name</td>
	  <td><input name="name" type="text" value="<%=self.escape(user.name)%>" size="40" maxlength="60" /></td></tr>
	<tr>
	  <td align="right">E-mail</td>
	  <td><input name="email" type="text" value="<%=self.escape(user.email)%>" size="40" maxlength="60" /></td></tr>
	<tr>
	  <td align="right">Homepage</td>
	  <td><input name="homepage" type="text" value="<%=self.escape(user.homepage)%>" size="40" maxlength="60" /></td></tr>
	<tr>
	  <td align="right">Password</td>
	  <td><input name="password1" type="password" size="20" maxlength="20" /></td></tr>
	<tr>
	  <td align="right">(repeat)</td>
	  <td><input name="password2" type="password" size="20" maxlength="20" />
	  <span class="error"><%=formErrors.get("password2","")%></span></td></tr>
	<tr><td />
	<td><input type="hidden" name="action" value="updateaccount" /><input type="submit" value="Submit" /></td>
	</tr>
  </table>
  </form>
