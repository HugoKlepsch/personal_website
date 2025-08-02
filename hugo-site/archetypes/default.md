---
date: '{{ .Date }}'
draft: true
title: '{{ replace (replace .File.ContentBaseName "-" " ") "_" " " | title }}'
---
