
import os
import sys
import re
import commands

def main(appname):
    print "Making tarball for webapp '%s'..." % appname,
    if appname=="frog":
        versionfile="frog/frog/__init__.py"
        distname="Frog-"
    elif appname=="filemgr":
        versionfile="filemgr/filemgr/__init__.py"
        distname="FileMgr-"
    else:
        raise ValueError("I don't know webapp '%s'"%appname)
    
    for line in open(versionfile):
        m=re.match('^VERSION.+=.*"(.+)"', line)
        if m:
            distname+=m.group(1)
            break
    print distname
    if not os.path.isdir("dist"):
        os.mkdir("dist")
    distname="dist/%s.tar.gz" % distname
    
    status,output=commands.getstatusoutput("tar --exclude=CVS -czf %s %s" % (distname, appname))
    if status!=0:
        print "ERROR"
        print output
    else:
        print "Done!", commands.getstatus(distname)
        
if __name__=="__main__":
    if len(sys.argv)!=2:
        print "usage: maketarball.py <webappname>"
    else:
        main(sys.argv[1])
