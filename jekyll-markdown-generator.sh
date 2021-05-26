#!/bin/bash
cat >index.md <<EOF
---
title: articles
date: `date '+%Y-%d-%m %H:%M:%S +02:00'`
layout: articles
---

![Name]({{ site.baseurl }}/uploads/img.png)

# Header

Text
EOF
