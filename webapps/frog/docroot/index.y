<%!--=========================================

 Multi-user 'portal' index page.
 You will see this page when accessing the root url
 and there is no 'rootdiruser' defined.

============================================--%>
<%@inputencoding="ISO-8859-1"%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Write what you want%>
<%@pagetemplatearg=left=<a href="about">About Frog</a>%>
<%@session=no%>
<%@import=import os%>
<%@import=import frog.util%>
<%

rdu=self.WebApp.getConfigItem("rootdiruser")
if rdu:
    target=frog.util.userURLprefix(self,rdu)
    self.Yhttpredirect(target)  # go to the rootdiruser page instead.

%>
<h2>Welcome to this website</h2>
<p>
This is a website where users spill their thoughts. The following individuals 
have registered here, have a look at what they are writing.
</p>
<%

if self.User:
    self.Request.getSession().logoutUser()
    self.User=None

users=self.ApplicationCtx.storageEngine.listBloggerUsers()

%>
<%if users:%>
<ul>
<%
def makeuserlink(user):
    return '<a href="'+frog.util.userURLprefix(self,user)+'">%s</a>' % self.escape(user)

def usersorter(a,b):
    return cmp(a.upper(), b.upper())

users=list(users)    
users.sort(usersorter)
for user in users:
    self.write("<li>"+makeuserlink(user)+"</li>")
%>
</ul>
<%else:%>
<i>Nobody has registered yet.</i>
<%end%>

<h4>Admin</h4>
<p>If you have admin access, you can go to the <a href="<%=url('admin.y')%>">Administrator pages</a>.</p>
