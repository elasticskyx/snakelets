<%!--====================================
    Generic Frog Customization forms.
=======================================--%>
<%@inputencoding="iso-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Customize your Frog account%>
<%@inherit=frog.CustomizeUtils.Customize%>
<%@indent=4spaces%>
<%

self.process()      # process the forms

user=self.User   # customize the currently logged in user

formErrors = self.RequestCtx.formErrors
displaystrings=user.displaystrings

%>
<h3>Customize your Frog</h3>
<%if self.RequestCtx.formMessage:%>
<p><span class="message">&bull; <%=self.RequestCtx.formMessage%> (might need a page refresh to show up)</span></p>
<%end%>  
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error: <%=formErrors["_general"]%></span>
<%end%>

<%!--================== FROG STRINGS AND DISPLAY SETTINGS =================--%>
  <form method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
  <h4>Frog configuration</h4>
    <table border="0" cellpadding="1" cellspacing="4">
	<tr>
	  <td align="right">Page title</td>
	  <td colspan="2"><input name="pagetitle" type="text" value="<%=self.escape(displaystrings["pagetitle"])%>" size="40" maxlength="40" /> <span class="error"><%=formErrors.get("pagetitle","")%></span></td></tr>
	<tr>
	  <td align="right">Subtitle</td>
	  <td colspan="2"><input name="subtitle" type="text" value="<%=self.escape(displaystrings["subtitle"])%>" size="40" maxlength="60" /></td></tr>
	<tr>
	  <td align="right">Menu text (XHTML)</td>
	  <td colspan="2"><input name="menutext" type="text" value="<%=self.escape(displaystrings["menutext"])%>" size="60" maxlength="200" /></td></tr>
	<tr>
	  <td align="right">Footer line (XHTML)</td>
	  <td colspan="2"><input name="footer" type="text" value="<%=self.escape(displaystrings["footertext"])%>" size="60" maxlength="200" /></td></tr>
	<tr>
	  <td align="right">HTML meta keywords</td>
	  <td colspan="2"><input name="metakeywords" type="text" value="<%=self.escape(user.metakeywords)%>" size="60" maxlength="200" /></td></tr>
	<tr>
	  <td align="right">HTML meta description</td>
	  <td colspan="2"><input name="metadescription" type="text" value="<%=self.escape(user.metadescription)%>" size="60" maxlength="200" /></td></tr>
	<tr>
	  <td />
	  <td>Page color style <select name="colorstyle">
	  <%
	  styles=["green","red","blue"]    # FIXED SEQUENCE
	  for i in range(3):
	      selected=""
	      if i==user.colorstyle:
	          selected='selected="selected"'
	      \%>
	   <option value="<%=i%>" <%=selected%>><%=styles[i]%></option>
	  <%end%></select>
	  </td><td>Smiley color <select name="smileycolor">
	  <%
	  styles=["yellow","red","blue"]   # FIXED SEQUENCE
	  for i in range(3):
	      selected=""
	      if i==user.smileycolor:
	          selected='selected="selected"'
	      \%>
	   <option value="<%=i%>" <%=selected%>><%=styles[i]%></option>
	  <%end%></select>
	  </td>
	</tr>
	<tr>
	  <td></td>
<%checked=""
if user.onlyregisteredcommenting: checked='checked="checked"'%>
	  <td colspan="2"><input name="onlyregisteredcommenting" type="checkbox" <%=checked%> id="c3" value="true" /> <label for="c3">Only allow registered users to place comments</label></td></tr>
	<tr>
	  <td></td>
<%checked=""
if user.usepuzzles: checked='checked="checked"'%>
	  <td colspan="2"><input name="usepuzzles" type="checkbox" <%=checked%> id="c4" value="true" /> <label for="c4">Use puzzles in comments, against spam bots</label></td></tr>
	<tr><td />
<%checked=""
if user.usecaptcha: checked='checked="checked"'%>
	  <td colspan="2"><input name="usecaptcha" type="checkbox" <%=checked%> id="c11" value="true" /> <label for="c11">Use captcha image in comments, against spam bots</label></td></tr>
	<tr><td />
<%checked=""
if user.mailnotify: checked='checked="checked"'%>
	  <td colspan="2"><input name="mailnotify" type="checkbox" <%=checked%> id="c8" value="true" /> <label for="c8">Receive mail notifications for new comments</label></td></tr>
	<tr>
	  <td></td>
<%checked=""
if user.searchenabled: checked='checked="checked"'%>
	  <td><input name="searchenabled" type="checkbox" <%=checked%> id="c1" value="true" /> <label for="c1">Enable 'Search' action</label></td>
<%checked=""
if user.showlogin: checked='checked="checked"'%>
	  <td><input name="showlogin" type="checkbox" <%=checked%> id="c2" value="true" /> <label for="c2">Show the 'Login' action</label></td>
	</tr>
	<tr><td />
<%checked=""
if user.countreads: checked='checked="checked"'%>
	  <td><input name="countreads" type="checkbox" <%=checked%> id="c5" value="true" /> <label for="c5">Count article reads</label></td>
<%checked=""
if user.rssenabled: checked='checked="checked"'%>
	  <td><input name="rssenabled" type="checkbox" <%=checked%> id="c6" value="true" /> <label for="c6">Enable RSS feeds</label></td></tr>
	<tr><td />
<%checked=""
if user.smileys: checked='checked="checked"'%>
	  <td><input name="smileys" type="checkbox" <%=checked%> id="c7" value="true" /> <label for="c7">Smileys default on</label></td>
<%checked=""
if user.customfrontpage: checked='checked="checked"'%>
	  <td><input name="customfrontpage" type="checkbox" <%=checked%> id="c9" value="true" /> <label for="c9">Custom front page</label></td></tr>
	<tr><td />
<%checked=""
if user.commentsmileys: checked='checked="checked"'%>
	  <td><input name="commentsmileys" type="checkbox" <%=checked%> id="c10" value="true" /> <label for="c10">Allow smileys in comments</label></td></tr>
	<tr><td />
	<td><input type="hidden" name="action" value="updatetexts"/><input type="submit" value="Submit" /></td>
	</tr>
	</table>
  </form>

<%!--================== PERSONAL/ACCOUNT INFORMATION =================--%>
  <form method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
  <h4>Account data</h4>
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
	  <td><input name="email" type="text" value="<%=self.escape(user.email)%>" size="40" maxlength="60" /> <span class="error"><%=formErrors.get("email","")%></span></td></tr>
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
	<tr>
	  <td></td>
	  <td><input name="forgetlogin" type="checkbox" id="ci1" /><label for="ci1">Clear my auto-login information</label></td></tr>
	<tr><td></td>
	<td><input type="hidden" name="action" value="updateaccount" /><input type="submit" value="Submit" /></td>
	</tr>
  </table>
  </form>

<h4>More customization</h4>
<p>&bull; <a href="customize_cats.y">Customize categories &hellip;</a></p>
<p>&bull; <a href="customize_links.y">Customize links &hellip;</a></p>
