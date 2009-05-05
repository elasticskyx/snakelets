<%!--========================================
      Customization forms for Categories.
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
<h3>Customize your Frog - Article Categories</h3>
<%if self.RequestCtx.formMessage:%>
<p><span class="message">&bull; <%=self.RequestCtx.formMessage%> (might need a page refresh to show up)</span></p>
<%end%>  
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error: <%=formErrors["_general"]%></span>
<%end%>

<%!--================== CATEGORY LIST EDITING =================--%>
<script type="text/javascript">
<!--
function selectedcat(name)
{
    document.getElementById("cat_name").value=name;
}
-->
</script>
  <form method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
  <h4>Categories</h4>
    <table border="0" cellpadding="1" cellspacing="4">
      <tr>
        <td valign="top"><select name="categories" size="6">
<%cats=user.categories.values()
cats.sort()
for cat in cats:%> <option value="<%=cat.id%>" onclick="selectedcat('<%=cat.name%>')"><%=self.escape(cat.name)%></option> <%end%>        
        </select></td>
        <td valign="top" style="white-space: nowrap"><input name="cat_remove" type="submit" value="remove" />
        &nbsp; <input name="cat_rebuildstats" type="submit" value="rebuild category counts" />
        <br />
        <br />
        <input id="cat_name" name="name" type="text" size="18" maxlength="18"/>
        <br />
        <input type="hidden" name="action" value="categoryedit" />
        <input name="cat_add" type="submit" value="Add new" />
        <input name="cat_rename" type="submit" value="Rename selected" /></td>
      </tr>
    </table>
  </form>

<p><a href="customize.y">&larr; back</a></p>