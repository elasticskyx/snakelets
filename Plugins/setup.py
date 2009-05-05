#!/usr/bin/env python

"""Snakelets Plugins setup script"""

from distutils.core import setup
import sys,os

def main():
    if sys.argv[1].startswith("install"):
        print "There's nothing to install automatically :-)"
        print "Just copy the required plugins to your Snakelet server's plugin directory."
        raise SystemExit

    setup(name="Snakelets-plugins",
            license="MIT",
            version="1.44",
            description = "Plugins for the Snakelets web application server",
            author = "Irmen de Jong",
            author_email="irmen@users.sourceforge.net",
            url = "http://snakelets.sourceforge.net/",
            packages=['cache','scheduler','compress', 'sharedauth'],
            platforms='any'
        )

if __name__=="__main__":
    main()
