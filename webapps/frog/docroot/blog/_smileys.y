<%!--

Editor Smiley buttons.
Requires editor.js to be loaded earlier.

--%>
<%if editor!='comment' or user.commentsmileys:%>   <%!-- only when writing an article, or when commentsmileys are allowed --%>
<%
if formValues.get("smileys") or smileysOnByDefault:
    checked_smileys='checked="checked"'
    smiley_table_display=''
else:
    checked_smileys=''
    smiley_table_display='display: none'
%>
<input type="checkbox" name="smileys" value="true" <%=checked_smileys%> id="smileys_check" onclick="e_toggletable('smileys_table',this.checked)" /><label for="smileys_check">Smileys</label>
<br />
<table class="smileys" id="smileys_table" style="<%=smiley_table_display%>">
<%
colors=["yellow","red","blue"]   # FIXED SEQUENCE

smileypath=url("img/smileys_%s" % colors[user.smileycolor])+'/'
%>
<tr><td class="smiley">
<a href="#" onclick="return e_writeTxt(' :-) ')"><img class="smiley" alt="X" title=":-)" src="<%=smileypath%>smile.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-D ')"><img class="smiley" alt="X" title=":-D" src="<%=smileypath%>biggrin.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' ^_^ ')"><img class="smiley" alt="X" title="^_^" src="<%=smileypath%>cheesygrin.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-/ ')"><img class="smiley" alt="X" title=":-/" src="<%=smileypath%>sad.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-( ')"><img class="smiley" alt="X" title=":-(" src="<%=smileypath%>frown.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-(( ')"><img class="smiley" alt="X" title=":-((" src="<%=smileypath%>cry.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-S ')"><img class="smiley" alt="X" title=":-S" src="<%=smileypath%>confused.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' ;-) ')"><img class="smiley" alt="X" title=";-)" src="<%=smileypath%>wink.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' 8-) ')"><img class="smiley" alt="X" title="8-)" src="<%=smileypath%>cool.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-P ')"><img class="smiley" alt="X" title=":-P" src="<%=smileypath%>tongue.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' o_o ')"><img class="smiley" alt="X" title="o_o" src="<%=smileypath%>eek.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-| ')"><img class="smiley" alt="X" title=":-|" src="<%=smileypath%>neutral.gif" /></a><br/>
</td>
<td class="smiley">
<a href="#" onclick="return e_writeTxt(' :-&gt; ')"><img class="smiley" alt="X" title=":-&gt;" src="<%=smileypath%>razz.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-# ')"><img class="smiley" alt="X" title=":-#" src="<%=smileypath%>redface.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' %-| ')"><img class="smiley" alt="X" title="%-|" src="<%=smileypath%>rolleyes.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' :-O ')"><img class="smiley" alt="X" title=":-O" src="<%=smileypath%>surprised.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' &gt;-( ')"><img class="smiley" alt="X" title="&gt;-(" src="<%=smileypath%>evil.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' &gt;-) ')"><img class="smiley" alt="X" title="&gt;-)" src="<%=smileypath%>twisted.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' (&gt;) ')"><img class="smiley" alt="X" title="(&gt;)" src="<%=smileypath%>arrow.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' (&lt;) ')"><img class="smiley" alt="X" title="(&lt;)" src="<%=smileypath%>arrowl.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' (?) ')"><img class="smiley" alt="X" title="(?)" src="<%=smileypath%>question.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' (!) ')"><img class="smiley" alt="X" title="(!)" src="<%=smileypath%>exclaim.gif" /></a><br/>
<a href="#" onclick="return e_writeTxt(' (L) ')"><img class="smiley" alt="X" title="(L)" src="<%=smileypath%>idea.gif" /></a><br/>
</td></tr>
</table>
<%end%>
