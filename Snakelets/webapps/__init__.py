# virtual host configuration

# NOTE: this is my (Irmen's) private config file,
# you should NOT use this but instead create your own.
# Look in the NON_DIST directory for a skeleton version to start with.

ENABLED=True


# webapps that will be loaded for the default config (if vhosts is disabled)
# use ["*"] to enable all of them
defaultenabledwebapps=["ROOT", "test", "manage", "account", "music", "shop", "shared1", "shared2"]


virtualhosts = {
	"charon" : ("test", "manage", "account", "music", "shop", "shared1", "shared2" ),
	"meuk": ("test",),
}


webroots = {
	"charon":	"ROOT",
}


aliases = {
	"charon.local": "charon",
    "localhost": "charon",
    "sub1.charon.local": "charon",
    "sub2.charon.local": "charon"
}

defaultvhost = "charon"
