<%!--==========================================
    Article + comments display page.
=============================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@session=yes%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=nofocus=True%>
<%@inherit=frog.CommentUtils.Comment%>
<%@method=templateArgs(self, request):
    request.setEncoding("UTF-8")
    entry = self.prepareEditBlogEntry()       # caches it on the session
    return {"pagetitle": entry.title}
%>
<%

import logging
log=logging.getLogger("Snakelets.logger")

user=self.SessionCtx.user
self.process(user)      # process the forms
    
arg=self.Request.getArg()
if arg=="edit":
    self.Yredirect("submit.y")

entry = self.prepareEditBlogEntry(True)    # get cached copy
    
date = entry.datetime[0]
Id = entry.id
commentsObj = self.prepareEditComments(date,Id)  # caches it on the session
comments=commentsObj.comments
numcomments=len(comments)

if self.Request.getParameter("editcomment"):
    self.Yredirect("editcomment.y")


formErrors = self.RequestCtx.formErrors
formValues = self.RequestCtx.formValues

previewcomment = hasattr(self.RequestCtx,"previewComment") and self.RequestCtx.previewComment
justdisplay = not self.Request.getParameter("action")

%>
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error:</span>
<br /><span class="error"><%=formErrors["_general"]%></span>
<%end%>

<%$include="_showArticle.y"%>
<%!--=============== ARTICLE, PREVIEW COMMENT, COMMENT LIST =================--%>
<h2>Article with comments</h2>
<%showArticle(entry,numcomments,withComments=True,preview=not justdisplay)%>
<h3>Comments (<%=numcomments%>)</h3>
<%if previewcomment:%>
 <hr style="height: 1px;" />
 <h4><a id="writecomment" style="text-decoration: none;"></a>Preview of your comment</h4>
 <%showComment(entry, self.RequestCtx.previewComment)%>
<%else:%>
 <%if numcomments>0:%>
  <%for comment in comments: showComment(entry, comment)%>
 <%else:%>
 <em>No comments for this article yet.</em>    
 <%end%>
<%end%>
<br />

<%!--=============== WRITE A COMMENT - FORM =================--%>
<hr style="height: 1px;" />
<%if entry.allowcomments:%>
  <h4><a id="writecomment" style="text-decoration: none;"></a>Write a comment</h4>
  <%if not user.onlyregisteredcommenting or self.User:%>
    <%$include="_editorstart.y"%>
    <form  method="post" action="<%=self.getURL()%>#writecomment" accept-charset="UTF-8">
<%
if self.User:
    #for logged-in users: erase any previous puzzles and captchas
    self.erasePuzzles()
else: %>    
      <%!-- for non-logged-in user: show userid and homepage fields editable, and 'remember me' checkbox --%>
    <table>
      <tr>
        <td>Your name</td><td><input type="text" name="name" value="<%=self.escape(formValues.get("name",""))%>" /> <span class="error"><%=formErrors.get("name","")%></span>
        &nbsp;
        <input type="checkbox" name="remember" id="c1" <%if formValues.get("remember"):%>checked="checked"<%end%> /><label for="c1">Remember personal data</label>
        </td>
      </tr>
      <tr>
        <td>E-mail</td><td><input type="text" name="email" value="<%=formValues.get("email","")%>" /> &nbsp; (only visible for blog owner) <span class="error"><%=formErrors.get("email","")%></span></td>
      </tr>
      <tr>
        <td>Homepage</td><td><input type="text" name="url" value="<%=self.escape(formValues.get("url",""))%>" /> <span class="error"><%=formErrors.get("url","")%></span></td>
      </tr>
   </table>
<%end%>
<table>
      <tr><td colspan="3">Text: <%if self.User:%>(posted as <strong><%=self.User.userid%></strong>)<%end%><span class="error"><%=formErrors.get("text","")%></span></td></tr>
      <tr>
      	<td colspan="2">
         <textarea id="commentarea" name="text" cols="80" rows="16" class="comment"><%=self.escape(formValues.get("text",""))%></textarea>
        </td>
	    <td style="white-space: nowrap"><%smileysOnByDefault=False; editor='comment'%><%$include="_smileys.y"%></td>
      </tr>
     <tr><td colspan="2"><%$include="_markupbuttons.y"%></td></tr>
     <tr><td colspan="2">&bull; <a href="<%=url('blog/markuphelp')%>">detailed help about markup</a></td></tr>
     <tr>
        <td>
          <input type="hidden" name="action" value="comment" />
          <input type="submit" name="comment-preview" value="Preview" />
          <input type="submit" name="comment-cancel" value="Cancel" />
        </td>
      </tr>
     </table>
     <table>
      <%if user.usepuzzles or user.usecaptcha:%>
        <tr><td colspan="3">You must answer the following to be able to submit.</td></tr>
          <%if user.usepuzzles:%>
             <%puzzle=self.makePuzzle()%>
              <tr>
                <td>How much is <%=puzzle%>?</td><td><input type="text" name="puzzle" /> &nbsp; <span class="error"><%=formErrors.get("puzzle","")%></span></td>
              </tr>
          <%end%>
          <%if user.usecaptcha:%>
             <%captcha=self.makeCaptcha()%>
              <tr>
                <td><img alt="[Captcha Image]" src="<%=url("currentcaptcha.jpg")%>" class="captcha"/></td>
                <td>Type the letters you see in the image.<br/>
                <sub>(Unreadable? Click 'Preview' for a new one)</sub><br/>
                <input type="text" name="captcha" /> <br/><span class="error"><%=formErrors.get("captcha","")%></span></td>
              </tr>
          <%end%>
      <%end%>
      <tr>
        <td/>
        <td align="right">
          <input type="submit" name="comment-submit" value="Submit comment" />
        </td>
      </tr>
    </table>    
    </form>
  <%else:%>
    <p>You are not logged in. Only registered users are allowed to write a comment.</p>
  <%end%>
<%else:%>
<p>It is not possible to add new comments to this article.</p>
<%end%>
