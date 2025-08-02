+++
date = '{{ .Date }}'
draft = true
title = '{{ replace .File.ContentBaseName "-" " " | replace .File.ContentBaseName "_" " " | title }}'
+++
