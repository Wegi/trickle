# trickle

A personal Social Media Hub. Get your Streams drop by drop.

## How to build

You need [node.js >= v0.10.31](http://nodejs.org/) and [node-webkit >= v0.10.4](https://github.com/rogerwang/node-webkit)

Build it with:
```bash
╭─user@host  ~/trickle
╰─$ zip -r trickle.nw * && nw trickle.nw
```

With OS X you might use the following command, because node-webkit is a little buggy when executed from the Terminal:
```bash
╭─user@host  ~/trickle
╰─$ zip -r trickle.nw * && open trickle.nw
```
