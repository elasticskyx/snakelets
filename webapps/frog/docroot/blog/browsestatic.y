<%!--================================================
    File browser for static files of the current user.
==================================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Your file collection%>
<%@pagetemplatearg=left=Browse%>
<%@session=user%>
<%@indent=4spaces%>
<%@import=import os,time,mimetypes,math,frog.util%>
<%

pathspec = self.Request.getPathInfo()[1:]

if "//" in pathspec or "/.." in pathspec:
    self.abort("relative paths not allowed")
    
path="%s/%s/%s" % (self.WebApp.getConfigItem("files"),self.User.userid,pathspec)

# Caching directory lister, outputs (filelist,dirlist) tuple
# Based upon dircache.py
_listdir_cache = {}
def listdir(path):
	try:
		cached_mtime, files, directories = _listdir_cache[path]
		del _listdir_cache[path]
	except KeyError:
		cached_mtime, files, directories = -1, [], []
	mtime = os.stat(path)[8]
	if mtime != cached_mtime:
		lizt = os.listdir(path)
		files=[ f for f in lizt if os.path.isfile(os.path.join(path,f)) if not f[0]=='.' ]
		directories=[ d for d in lizt if os.path.isdir(os.path.join(path,d)) if not d[0]=='.' ]
	_listdir_cache[path] = mtime, files, directories
	return files,directories

files,dirs = listdir(path)
files.sort()
dirs.sort()
%>
<h2>Location: /<%=self.escape(pathspec)%></h2>
<%if pathspec:%>
  <p><a href="<%=self.escape("%s/%s.." % (self.getURL(), pathspec))%>"><img src="<%=asset('img/scrollup.gif')%>" alt="" /> (parent)</a> <br /></p>
<%end%>
<p>
<%for d in dirs:%>
    <img src="<%=asset('img/window.gif')%>" alt="" /><a href="<%=self.escape("%s/%s%s/"%(self.getURL(),pathspec,d))%>"><%=self.escape(d)%></a>/ <br />
<%end%>
</p>
<%if not files:%><p>(no files)</p>
<%else:%>
  <br />
  <table class="overview">
  <tr>
  <th /><th>filename</th><th>size</th><th>date</th><th>@link</th>
  </tr>

<%
for f in files:
    stats=os.stat(os.path.join(path,f))
    mtime=time.localtime(stats.st_mtime)
    mtype=mimetypes.guess_type(f)
    if mtype:
        mtype=mtype[0] or ""
    if mtype.startswith("image"):  icon = "picture.gif"
    elif mtype.startswith("text"): icon = "text.gif"
    elif mtype.startswith("audio"): icon = "sound.gif"
    elif mtype.startswith("video"): icon = "movie.gif"
    else:                          icon = "disk.gif"

    link = self.escape("%s%s" % (pathspec,f))
    if link.startswith('@'):
        link=' '+link
    # that made sure that a @@-link works okay
    \%>
  <tr>
      <td><img src="<%=asset('img/'+icon)%>" alt="" /></td>
      <td><a href="<%=self.escape("%sfiles/%s/%s%s"%(self.URLprefix,self.User.userid,pathspec,f))%>"><%=self.escape(f)%></a></td>
      <td><%=int(math.ceil(stats.st_size/1024.0))%> Kb</td>
      <td><%=frog.util.mediumdatestr(mtime)%> <%=frog.util.isotimestr(mtime)%></td>
      <td>[@<%=link%>]</td>
  </tr>
  <%end%>
  </table>
<%end%>
<br />
<p>
<span class="count">Filesystem location: <%=self.escape(path)%></span>
<br />
<span class="count">If opened in a new window, just close the window</span>
<br />
<span class="count">If <em>not</em> opened in a new window, click <a href="<%=url('blog/submit')%>">here</a> to go back</span>
</p>
