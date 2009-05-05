<%!--===========================================
    SUBMIT a NEW ARTICLE,
    or EDIT an EXISTING ARTICLE.
==============================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Submit article%>
<%@import=import frog.util%>
<%@inherit=frog.SubmitUtils.Submit%>
<%
import logging
log=logging.getLogger("Snakelets.logger")

log.info("submit.y")

user=self.SessionCtx.user

self.process(user)      # process the forms

if not self.RequestCtx.formValues:
	smileysOnByDefault=user.smileys
else:
	smileysOnByDefault=None	


edit = self.Request.getArg()=="edit"
if edit:
    if self.Request.getSession().isNew():
        self.abort("Session is invalid. Have (session-)cookies been disabled?")
    entry = self.prepareEditBlogEntry()    # caches it on the session
    if entry and not (hasattr(self.RequestCtx,"previewArticle") and self.RequestCtx.previewArticle):
        # we're editing, and it's not a preview screen, so prefill the form 
        # with the values from the blog entry we've just loaded.
        self.RequestCtx.formValues["title"]=entry.title
        self.RequestCtx.formValues["category"]=entry.category
        self.RequestCtx.formValues["text"]=entry.text
        self.RequestCtx.formValues["text2"]=entry.text2
        self.RequestCtx.formValues["smileys"]=entry.smileys
        self.RequestCtx.formValues["articletype"]=entry.articletype
        self.RequestCtx.formValues["allowcomments"]=entry.allowcomments
    formurl=self.getURL()+"?edit"
    submitvalue = "update-article"
else:
    formurl = self.getURL()+"?new"
    submitvalue = "submit-article"


formErrors = self.RequestCtx.formErrors
formValues = self.RequestCtx.formValues

if not formValues.get("text"):
    formValues["allowcomments"]=True
%>

<%$include="_categoryselectbox.y"%>
<%$include="_showArticle.y"%>


<%!--================== PREVIEW ARTICLE =================--%>
<%if hasattr(self.RequestCtx,"previewArticle") and self.RequestCtx.previewArticle:%>
 <h4>Preview of your changes:</h4>
 <%showArticlePreview(self.RequestCtx.previewArticle)%>
 <hr/> 
<%end%>

<%!--================== EDIT/WRITE ARTICLE FORM =================--%>
<%if edit:%><h4>Edit the article written by you on <%=frog.util.mediumdatestr(entry.datetime[0])%>, <%=entry.datetime[1]%></h4>
<h5>There are <%=self.SessionCtx.commentCount%> comments to this article.
<a href="<%=frog.util.articleURL(self,entry)%>">Return to article and comments.</a></h5>
<%else:%><h4>Write a new article.</h4>
<%end%>
<%if formErrors.has_key("_general"):%>
<span class="error">There was an error:</span>
<br /><span class="error"><%=formErrors["_general"]%></span>
<%end%>

<script src="<%=url('blog/articletype.js')%>" type="text/javascript"></script>
<%$include="_editorstart.y"%>

<form action="<%=formurl%>"  method="post" accept-charset="UTF-8">
<table>
  <tr>
    <td>Category</td>
    <td><%createCategorySelectbox("category", formValues.get("category"), user)%>
    <span class="error"><%=formErrors.get("category","")%></span></td>
  </tr>
  <tr>
    <td>Title</td>
    <td colspan="2"><input name="title" type="text" size="60" value="<%=self.escape(formValues.get("title",""))%>" /> <span class="error"><%=formErrors.get("title","")%></span></td>
  </tr>
<!-- SELECT ARTICLE TYPE -->
<%
articletype=formValues.get("articletype","normal")
if articletype=="normal":
    r_1_checked='checked="checked"'
    r_2_checked=''
    normal_fields_display=''
    split_fields_display='style="display: none"'
elif articletype=="split":
    r_1_checked=''
    r_2_checked='checked="checked"'
    normal_fields_display='style="display: none"'
    split_fields_display=''

# normal_fields_display=split_fields_display=''    
%>
<tr><td>Article type:</td><td><input id="at_r_1" type="radio" name="articletype" value="normal" <%=r_1_checked%> onclick="return articleType('normal')" />
<label for="at_r_1">normal</label>
<input id="at_r_2" type="radio" name="articletype" value="split" <%=r_2_checked%> onclick="return articleType('split')"/>
<label for="at_r_2">split</label>
</td></tr>
</table>
<table>
<tr><td colspan="3">Article: <span class="error"><%=formErrors.get("text","")%></span></td></tr>
<!-- NORMAL ARTICLE INPUT FIELDS -->
<tr>
 <td colspan="2">
  <div class="nomargin" id="normal_fields" <%=normal_fields_display%>>
   <textarea id="text_normal" name="text" cols="80" rows="20" class="comment" onselect="e_storeCursor(this)" onkeyup="e_storeCursor(this)" onclick="e_storeCursor(this)"><%=self.escape(formValues.get("text",""))%></textarea>
   <br />
  </div>
<!-- SPLIT ARTICLE INPUT FIELDS -->
  <div class="nomargin" id="split_fields" <%=split_fields_display%>>
   <textarea id="text_split" name="text" cols="80" rows="8" class="comment" onselect="e_storeCursor(this)" onkeyup="e_storeCursor(this)" onclick="e_storeCursor(this)"><%=self.escape(formValues.get("text",""))%></textarea>
   <br /><sub>(read on...)</sub><br />
   <textarea id="text2_split" name="text2" cols="80" rows="15" class="comment" onselect="e_storeCursor(this)" onkeyup="e_storeCursor(this)" onclick="e_storeCursor(this)"><%=self.escape(formValues.get("text2",""))%></textarea>
  </div>
 </td> 
 <td rowspan="2" style="white-space: nowrap"><%editor='article'%><%$include="_smileys.y"%></td>
</tr>
<tr><td colspan="2"><%$include="_markupbuttons.y"%></td></tr>
<tr>
 <td colspan="2">&bull; <a href="<%=url('blog/markuphelp')%>">detailed help about markup</a>
 &bull; <a href="<%=url('blog/browsestatic.y')%>">browse your files</a>   <%!-- THE .y SUFFIX IS NEEDED IN THIS LINK --%>
 </td>
</tr>
<tr>
<%
if formValues.get("allowcomments"):
    checked_allow='checked="checked"'
else:
    checked_allow=''
%>
	  <td>
       <input name="allowcomments" type="checkbox" <%=checked_allow%> id="c_allow" value="true" /> <label for="c_allow">Allow comments?</label>
      </td>
  </tr>
  <tr>
    <td><input type="hidden" name="action" value="submit" />
      <input name="preview-article" type="submit" value="Preview" />
      <input name="<%=submitvalue%>" type="submit" value="Submit" /> </td>
    <td align="right">
<%if edit:%>
     <input name="delete-article" type="submit" value="Delete it" style="color: red"/>
<%end%>
    <input name="cancel-article" type="submit" value="Cancel changes" /> </td>
  </tr>
</table>
</form>
