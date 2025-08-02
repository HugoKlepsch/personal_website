---
date: '{{ .Date }}'
draft: true
title: '{{ replace (replace .File.ContentBaseName "-" " ") "_" " " | title }}'
tags:
  - 'Bad Idea'
---
