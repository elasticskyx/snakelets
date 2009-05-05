#
#   Blacklist anti-spam.
#   The blacklist is assumed to be the MovableType blacklist.
#   It used to do auto-updating, but the maintainer has removed the
#   master blacklist website. So only a static file is cached.
#

import urllib2
import os, re

import logging
log=logging.getLogger("Snakelets.logger")


CACHEFILE = "blacklist.txt"


class MTBlackList:
    def __init__(self, storageDir):
        self.cachefile=os.path.join(storageDir, CACHEFILE)
        log.debug("blacklist cachefile="+self.cachefile)
        self.blacklist=[]
        self.updated_file=None
        self.last_mtime=0
        self.__parselist()

    def __str__(self):
        if self.blacklist:
            return "Blacklist, timestamp=%s, %d entries" % (self.updated_file, len(self.blacklist))
        else:
            return "Blacklist NOT FOUND OR EMPTY, NO CHECKING DONE!"

    # update the spamchecker (in this case: the blacklist file)
    def update(self):
        log.info("updating blacklist from file")
        self.__parselist()

    # check the text for spam, return None if okay, errormessage if spam.
    def check(self, text):
        if text:
            for rx in self.blacklist:
                if rx.search(text):
                    return "blacklisted url found"
        return None

    def __parselist(self):
        if not os.path.isfile(self.cachefile):
            msg="*** ANTISPAM BLACKLIST NOT FOUND; ANTISPAM DISABLED ***"
            log.warn(msg)
            print msg
            return
        mtime=os.path.getmtime(self.cachefile)
        if mtime==self.last_mtime:
            log.info("not a new version, don't re-read")
            return
        else:
            self.last_mtime=mtime
            
        data=open(self.cachefile,"r").read()
        match=re.search(r"^#\s+Last update:\s+(.+)\s*$",data,re.IGNORECASE | re.MULTILINE)
        if match:
            list_updated=match.group(1).strip()
            self.updated_file=list_updated
        else:
            self.updated_file=None
        # strip the comments
        self.blacklist=[]
        for line in data.split('\n'):
            line=line.strip()
            if line and not line.startswith('#'):
                match=re.match(r"(.+)\s+#.+$", line)

                if match:
                    line=match.group(1).strip()
                self.blacklist.append(line)
        self.blacklist = [re.compile(rx, re.IGNORECASE) for rx in self.blacklist]
        if self.blacklist:
            log.debug("using blacklist @ %s (%d entries)" % (self.updated_file,len(self.blacklist) ) )
        else:
            msg="*** ANTISPAM BLACKLIST CONTAINS NO ENTRIES; ANTISPAM DISABLED ***"
            log.warn(msg)
            print msg


if __name__=="__main__":
    # test code
    m=MTBlackList("/tmp")
    print "#entries=",len(m.blacklist)
    print "updated",m.updated_file

