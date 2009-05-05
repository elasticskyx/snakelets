#############################################################################
#
#	$Id: __init__.py,v 1.5 2005/05/01 17:18:10 irmen Exp $
#	Task Scheduler plugin (uses Kronos task scheduler)
#
#	This is part of "Snakelets" - Python Web Application Server
#	which is (c) Irmen de Jong - irmen@users.sourceforge.net
#
#############################################################################

from snakeserver.plugin import ServerPlugin
import kronos
import logging

log=logging.getLogger("Snakelets.logger")

ENABLED=True
PLUGINS=[ "SchedulerPlugin" ]   # this MUST be the name ("SchedulerPlugin"), the server looks for this.

class SchedulerPlugin(ServerPlugin, kronos.ThreadedScheduler):
    # PLUGIN_NAME="Scheduler"   # the classname is okay so use that
    # PLUGIN_SEQ=...  # sequence doesn't matter; there is only 1 scheduler
    def __init__(self):
        ServerPlugin.__init__(self)
        kronos.ThreadedScheduler.__init__(self)
    def plug_init(self, server):
        log.debug("Scheduler plugin init")
    def plug_serverStart(self, server):
        log.debug("Scheduler plugin start")
        print "KRONOS START"
        self.start()
    def plug_serverStop(self, server):
        log.debug("Scheduler plugin stop")
        print "KRONOS STOP"
        self.stop()
