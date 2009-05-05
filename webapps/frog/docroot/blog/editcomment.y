<%!--========================================
        Edit an existing comment.
=========================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@inherit=frog.CommentUtils.Comment%>
<%
import logging
log=logging.getLogger("Snakelets.logger")

log.info("editcomment.y")

user=self.SessionCtx.user

self.process(user)      # process the forms

commentid=int(self.Request.getParameter("editcomment"))
comment=self.determineSelectedComment(commentid)
       
if not comment:
    self.abort("comment not found")

entry = self.prepareEditBlogEntry()       # caches it on the session

formErrors = self.RequestCtx.formErrors
formValues = self.RequestCtx.formValues

%>
<%!--=================== PREVIEW =================--%>
<%$include="_showArticle.y"%>
<%$include="_editorstart.y"%>
<%if hasattr(self.RequestCtx,"previewComment") and self.RequestCtx.previewComment:%>
 <h4>Preview of your changes:</h4>
 <%showComment(entry, self.RequestCtx.previewComment, True)%>
 <hr/> 
<%end%>
<%!--=================== EDIT FORM =================--%>
<h4>Edit the comment</h4>
<form  method="post" action="<%=self.getURL()%>" accept-charset="UTF-8">
<p><input type="hidden" name="editcomment" value="<%=commentid%>" /></p>
<table>
  <tr>
    <td>Commenter's name</td><td><input type="text" name="name" value="<%=comment.author[0]%>" disabled="disabled" /> <span class="error"><%=formErrors.get("name","")%></span></td>
  </tr>
  <tr>
    <td>Commenter's homepage</td><td><input type="text" name="url" value="<%=comment.author[1] or ''%>" /> <span class="error"><%=formErrors.get("url","")%></span></td>
  </tr>
</table>
<table>
  <tr><td colspan="3">Text: <span class="error"><%=formErrors.get("text","")%></span></td></tr>
  <tr>
  	<td colspan="2"><textarea id="commentarea" name="text" cols="80" rows="16" class="comment" onselect="e_storeCursor(this)" onkeyup="e_storeCursor(this)" onclick="e_storeCursor(this)"><%=self.escape(comment.text)%></textarea></td>
  	<%
  	    smileysOnByDefault=comment.smileys
  	    editor='comment'
  	%>
    <td style="white-space: nowrap"><%$include="_smileys.y"%></td>
  </tr>
<tr><td colspan="2"><%$include="_markupbuttons.y"%></td></tr>
<tr><td colspan="2">&bull; <a href="<%=url('blog/markuphelp')%>">detailed help about markup</a></td></tr>
  <tr>
    <td style="white-space: nowrap">
      <input type="hidden" name="action" value="editcomment" />
      <input type="submit" name="comment-preview" value="Preview" />
      <input type="submit" name="comment-submit" value="Submit" />
    </td>
    <td align="right">
      <input type="submit" name="comment-delete" value="Delete it" style="color: red"/>
      <input type="submit" name="comment-cancel" value="Cancel changes" />
    </td>
  </tr>
</table>
</form>
