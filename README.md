tor-nginx-golang-skeleton
=========================

This is an exercise in building a more or less self-contained set of
containers necessary to run a `golang` webapp on Tor.

Building
--------

Look at `env.sh.example`, once you're done run `./deploy.zsh`. It **requires**
`zsh` because all the cool kids use `zsh` these days.

It requires a backend app you can run on its own the usual way
(`$ docker run -p 31337:31337 backend-app`). If all is configured properly,
the deploy script should bring your website on Tor and you can browse it
freely.

### Backend?

There is no backend app here. You need to build it yourself. Here's a demo
you can dockerise:

```go
package main

import "github.com/gin-gonic/gin"

func main() {
        r := gin.Default()
        r.GET("/", func(c *gin.Context) {
                c.String(200, "مرحبا")
        })

        r.Run(":31337")  // This is BACKEND_PORT, make sure they match
}
```

In case you don't know much about dockerising `golang` apps, you should
probably do some reading beforehand (hint: search for how to do it using
modules and a scratch image).

### Keys

You should run one of those programs that generate `.onion` URLs (e.g.
[this](https://github.com/cathugger/mkp224o)) and then put some of the
resulting directories (e.g. one v2 and one v3 URL) inside
`LOCAL_SECRETS_PATH` so that each of `LOCAL_SECRETS_PATH`'s subdirectories
contains each site's keys and hostname. The script is somehow intelligent
and just scans the directories and fills the suitable files for you.

You will also need to set restrictive permissions to those directories and
their files (700 should be fine).

### Notes

* Everything in the `tor` container runs as root and `LOCAL_SECRETS_PATH` is
  expected to be owned by `root`. You might be opinionated on whether this
  is a good idea.
* All the images are tiny since they're based on Alpine.
* As you can notice, this doesn't expose any ports. Obviously, because
  that's not how Tor works.
* Wait, are you saying that potentially any backend app serving anything
  on port `BACKEND_PORT` works fine and this has nothing to do with `golang`
  at all? That's right.
