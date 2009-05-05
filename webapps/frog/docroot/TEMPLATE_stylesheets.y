<%!--=========================================

 INCLUSION TEMPLATE to include the CSS links in the <head>.
 (and to set the configured one (0,1,2) as default css)

============================================--%>
<%
css=["alternate stylesheet"]*3
if hasattr(self.SessionCtx, "user"):
    css[self.SessionCtx.user.colorstyle]="stylesheet"
else:
    css[0]="stylesheet"
%>
<link rel="stylesheet" type="text/css" href="<%=url("css/simple.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=url("css/theme.css")%>" />
<link rel="<%=css[0]%>" type="text/css" href="<%=url("css/colors_green.css")%>" title="green" />
<link rel="<%=css[1]%>" type="text/css" href="<%=url("css/colors_red.css")%>" title="red" />
<link rel="<%=css[2]%>" type="text/css" href="<%=url("css/colors_blue.css")%>" title="blue" />
