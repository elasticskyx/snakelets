<%!--=========================================

 Forgotten-password instructions.

============================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Forgotten your password?%>
<%@pagetemplatearg=left=Unfortunate!%>
<h4>You have forgotten your password...</h4>
<p>...that is unfortunate. Because it is impossible to retrieve your password from
the database (the password itself is never stored). We can only help you by temporarily
resetting your password to something else. Please contact the adminstrator of
this website to do this.</p>
<br />
<table>
<tr> <td align="right">Website administrator:</td><td><%=self.WebApp.getConfigItem("site-admin-name")%></td> </tr>  
<tr> <td /><td><%=self.WebApp.getConfigItem("site-admin-contact")%></td> </tr>  
</table>
<br /><br /><br />
<%
back=self.Request.getReferer()
if not back:
    back=self.URLprefix
%>
<p><a href="<%=back%>">&larr; go back</a></p>
