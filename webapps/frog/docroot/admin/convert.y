<%!--======================================
  Convert old blog data to new storage format.
=========================================--%>
<%@pagetemplate=TEMPLATE_index.y%>
<%@pagetemplatearg=title=Convert blog data%>
<%@pagetemplatearg=left=From old to new%>
<%@pagetemplatearg=nofocus=True%>

<%@import=import frog.xmlstorage.ConvertUtils as ConvertUtils%>
<%@import=import frog%>
<%

storageEngine=self.ApplicationCtx.storageEngine
users=storageEngine.listUsers(False)
if users:
    user=users.pop()
    users.add(user) # put it back
    print "SCANNING FOR USER",user # XXX
    existingVersion = [user, ConvertUtils.scanVersion(storageEngine,user)]
 
%>
<h4>Convert old blog data to current storage format (<%=frog.STORAGE_FORMAT%>)</h4>
<%if not users:%>
<p><span class="error">There is no blog data to convert (no users)</span></p>
<%else:%>

    <p>Storage location = <%=self.escape(storageEngine.storagebase)%></p>
    <p>Detected current storage format: <%=existingVersion[1]%></p>
    <%if not existingVersion[1]:%>
        <%existingVersion[1]="Frog 1.0 beta"%>
        <p>[no version found, assuming '<%=existingVersion[1]%>']</p>
    <%end%>
    <%if existingVersion[1] == frog.STORAGE_FORMAT:%>
        <p><strong>Storage Version is current. Nothing needs to be done.</strong></p>
    <%else:%>
        <p><strong>Data needs conversion.</strong></p>
        <%if not self.Request.getParameter("confirm-conversion"):%>
            <p><strong style="color:red">MAKE SURE THAT YOU HAVE A BACKUP OF YOUR BLOG DATA DIRECTORY!</strong></p>
            <p>(the filesystem location = <%=self.WebApp.getConfigItem('storage')%> )</p>
            <form action="<%=self.getURL()%>" method="post">
            <p><input type="submit" name="confirm-conversion" value="Start Conversion" /></p>
            </form>
        <%else:%>
            <%
            converter=ConvertUtils.getConverter(existingVersion[1])
            if converter:
                self.write("<hr />")
                self.write("<em>If you see an error below, the conversion failed, AND YOU HAVE TO RESTORE THE BACKUP OF YOUR BLOG DATA!</em>")
                converter.convert(self, storageEngine)
                storageEngine.listUsers(False)  # force reload of user list
                self.write("<hr />")
                if converter.errors:
                    self.write("<p><strong>%d errors occurred. Restore your backup and look at the log!</strong></p>" % len(converter.errors))
                else:
                    self.write("<p><strong>Conversion finished!</strong></p>")
                    self.write("<p><strong>Data files are now version "+converter.TARGETVERSION+"</strong></p>")
                    if converter.TARGETVERSION != frog.STORAGE_FORMAT:
                        self.write("<p><strong><em>That is not the most current version. <a href=\""+self.getURL()+"\">Refresh</a> the page to do additional conversions.</em></strong></p>")
                    else:
                        self.write("<p><em>Conversion complete!</em></p>")
            else:
                self.write('<p><span class="error">No suitable converter found to do the conversion!</span></p>')
            %>
        <%end%>
    <%end%>
<%end%>

<p><a href="<%=url('admin/')%>">Back to menu</a></p>
