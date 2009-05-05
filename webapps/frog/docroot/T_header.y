<%!--=========================================

 INCLUSION TEMPLATE for the TOP TITLE BAR and ACTION BAR.
 (included from the main template page)
 displaystrings is set by the template itself.

============================================--%>
<%@import=import frog.util, frog%>
<%
bloguser=self.SessionCtx.user
nummessages=self.SessionCtx.storageEngine.countAllBlogEntries()
userURLprefix=frog.util.userURLprefix(self)

# we have these actions:
# Submit | FileMgr | Search | Customize | CustomizeSimple | MyPage | Logout | Login

SUBMITACTION = ("Submit", self.URLprefix+"blog/submit")
FILEMGRACTION = ("Files", self.WebApp.getConfigItems().get("filemgr-url") )
SEARCHACTION = ("Search", self.URLprefix+"blog/search")
CUSTOMIZEACTION = ("Customize", self.URLprefix+"blog/customize")
CUSTOMIZESIMPLEACTION = ("Customize", self.URLprefix+"blog/customizesimple")
LOGOUTACTION = ("Logout", self.URLprefix+"blog/logout")
LOGINACTION = ("Login", userURLprefix+"?login")
if self.User:
    MYPAGEACTION = ("My Page", frog.util.userURLprefix(self, self.User.userid) )

actions = []

# Determine which actions should be available.

if self.User:
    # user is logged in.
    if self.User.hasPrivilege(frog.USERPRIV_BLOGGER):
        # it is the blog's owner
        actions.append( SUBMITACTION )
        if self.WebApp.getConfigItems().get("filemgr-url"):
            returnurl=self.urlescape(frog.util.userURLprefix(self))
            FILEMGRACTION = (FILEMGRACTION[0], FILEMGRACTION[1]+"?src=frog&amp;user="+self.User.userid+"&amp;returnurl="+returnurl)
            actions.append( FILEMGRACTION )
        actions.append( SEARCHACTION )
        actions.append( CUSTOMIZEACTION )
    else:
        # just another user
        if bloguser.searchenabled:
            actions.append( SEARCHACTION )
        if self.User.userid!=bloguser.userid and self.User.accounttype==frog.ACCOUNTTYPE_BLOGGER:
            # user has own page too
            actions.append( MYPAGEACTION )
        else:
            actions.append( CUSTOMIZESIMPLEACTION )
    actions.append( LOGOUTACTION )
else:
    # not logged in.
    if bloguser.searchenabled:
        actions.append( SEARCHACTION )
    if bloguser.showlogin:
        actions.append( LOGINACTION )
    
actions = [ '<a href="'+actionurl+'">'+action+'</a>' for action,actionurl in actions ]

%>
<%!-- ===== MAIN PAGE TITLE ==== --%>
<div class="heading"><h1><a class="invisible" href="<%=frog.util.userURLprefix(self)%>"><%=self.escape(displaystrings['pagetitle'])%></a></h1>
<%=self.escape(displaystrings['subtitle'])%></div>
<%!-- ===== ACTIONS BAR ==== --%>
<div class="hnav">
<span id="choices">
<%if actions:
    self.write("actions &raquo; ")
else:
    self.write("&nbsp;")

self.write(" &bull; ".join(actions))

%>
</span>
 <span id="stats">
<%if self.User:%><%=self.escape(self.User.userid)%> logged in &bull; <%end%><%=nummessages%> articles &bull; <%=frog.util.mediumdatestr()%></span>
</div>
