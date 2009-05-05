<%!--========================================
      Customization forms for Links.
===========================================--%>
<%@inputencoding="iso-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@inherit=frog.CustomizeUtils.Customize%>
<%@indent=4spaces%>
<%

self.process()      # process the forms

user=self.User   # customize the currently logged in user

formErrors = self.RequestCtx.formErrors
displaystrings=user.displaystrings

%>
<h3>Customize your Frog - Links</h3>
<%if self.RequestCtx.formMessage:%>
<p><span class="message">&bull; <%=self.RequestCtx.formMessage%> (might need a page refresh to show up)</span></p>
<%end%>  
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error: <%=formErrors["_general"]%></span>
<%end%>

<%!--================== CUSTOM LINKS LIST EDITING =================--%>
<script type="text/javascript">
<!--
function selectedlink(name,url)
{
    document.getElementById("link_name").value=name;
    document.getElementById("link_url").value=url;
}
-->
</script>
  <form method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
   <h4>Custom Links</h4>
    <table border="0" cellpadding="1" cellspacing="4">
      <tr>
        <td valign="top"><select name="links" size="6">
<%
links=user.links.items()
def linksorter(a,b):
    return cmp(a[0].upper(), b[0].upper())
links.sort(linksorter)
for name,url in links:%> <option title="<%=self.escape(url)%>" onclick="selectedlink('<%=name%>','<%=url%>')"><%=self.escape(name)%></option> <%end%>       
        </select></td>
      <td valign="top" style="white-space: nowrap"><input name="link_remove" type="submit" value="remove" />
            <br />
            <br />
            Name: <input id="link_name" name="name" type="text" />
            <br />
            URL: <input id="link_url" name="url" type="text" size="30" />
			<br />
            <input type="hidden" name="action" value="linksedit" />
            <input name="link_add" type="submit" value="add" />
        </td>
      </tr>
  </table>
  </form>

<p><a href="customize.y">&larr; back</a></p>
