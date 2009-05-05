<%!--================================================
    Help page on the BBCode-like markup language.
==================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE.y%>
<%@pagetemplatearg=pagetitle=Markup help%>
<h2>Markup information</h2>
<p>Frog understands a markup format similar to the popular <em>BBCode</em> that is often used in forum software.
You can read the <a href="http://www.phpbb.com/phpBB/faq.php?mode=bbcode">BBCode faq</a> if you want more info,
because this page only shows the basics. Here is what Frog understands:</p>
<br />
<p><em>Single line breaks will be ignored; lines are joined together (use the
line break tag to separate lines), double line breaks (one empty line) become paragraph breaks.
Urls or email addresses won't be automagically converted into hyperlinks.</em>
</p>
<p><em><strong>Markup, quoting:</strong></em></p>
<table>
<tr><td>[b]some bold text[/b]</td><td>&rarr;</td><td><b>some bold text</b></td></tr>
<tr><td>[i]some italic text[/i]</td><td>&rarr;</td><td><i>some italic text</i></td></tr>
<tr><td>[u]some underlined text[/u]</td><td>&rarr;</td><td><span class="underlined">some underlined text</span></td></tr>
<tr><td>[tt]some typewriter text[/tt]</td><td>&rarr;</td><td><tt>some typewriter text</tt></td></tr>
<tr><td>[center]some centered text[/center]</td><td>&rarr;</td><td>text will be centered on the page</td></tr>
<tr><td>[code]code block[/code]</td><td>&rarr;</td><td>preformatted <code>code block</code></td></tr>
<tr><td>[quote]quoted text[/quote]</td><td>&rarr;</td><td>quote a part of another text (can be nested)</td></tr>
<tr><td>blah blah [/]</td><td>&rarr;</td><td>line break after 'blah blah'</td></tr>
</table>
<p><em><strong>Hyperlinks, images:</strong></em></p>
<table>
<tr><td>[url]http://www.google.com[/url]</td><td>&rarr;</td><td><a href="http://www.google.com">http://www.google.com</a></td></tr>
<tr><td>[url=www.google.com]link-text[/url]</td><td>&rarr;</td><td><a href="http://www.google.com">link-text</a></td></tr>
<tr><td>[img]http://..../frog.gif[/img]</td><td>&rarr;</td><td><img class="markuphelp" src="<%=self.Request.getBaseURL()+url('img/frog.gif')%>" alt="a frog" /> 
 <span class="count">(external image link)</span></td></tr>
<tr><td>[img|w=&hellip;,h=&hellip;,alt=&hellip;,float=&hellip;]</td><td>&rarr;</td><td>Add special html tags to the image. Recognised tages are
    <strong>w</strong> (width), <strong>h</strong> (height), <strong>alt</strong> (alt-text) and <strong>float</strong>
    (float, left or right). Separate multiple tags with commas.</td></tr>
</table>
<p><em><strong>Lists:</strong></em></p>
<table>
<tr><td>[list] &hellip; [/list]</td><td>&rarr;</td><td>unordered list</td></tr>
<tr><td>[list=1] &hellip; [/list]</td><td>&rarr;</td><td>ordered list 1,2,3...</td></tr>
<tr><td>[list=a] &hellip; [/list]</td><td>&rarr;</td><td>ordered list a,b,c...</td></tr>
<tr><td>[*]list item</td><td>&rarr;</td><td>use this for each item inside a list (no close tag)</td></tr>
</table>
<p><em><strong>Embedding of uploaded files:</strong></em></p>
<table>
<tr><td>[@filename.zip]</td><td>&rarr;</td><td>Download link from the static files directory. If the file is an image, it will be embedded (shown) in the article. Filename may not contain pipe character ('|').</td></tr>
<tr><td>[@filename.jpg|tag=&hellip;]</td><td>&rarr;</td><td>Add special html tags to the embedded image. See above at [img] 
    what attributes are recognised. The filename may not contain a pipe character ('|').</td></tr>
<tr><td>[@@filename.gif]</td><td>&rarr;</td><td>Download image from the static files directory (force <em>no</em> image embedding)</td></tr>
</table>
<p>These tags also allow remote files (starting with http:) for simplicity, and will output nice links, but you can use the normal [img] and [url] tags for that too (they output just the simple links)</p>
<p><em><strong>Article cross-linking:</strong></em></p>
<table>
<tr><td>[@:articleid]</td><td>&rarr;</td><td>Link to another article, articleid is the last part from 
the article's parmalink (for instance 2004-10-29/1).</td></tr>
</table>
<br />
<p>Press <a href="javascript:history.go(-1);">back</a> to go back to the edit page.</p>




