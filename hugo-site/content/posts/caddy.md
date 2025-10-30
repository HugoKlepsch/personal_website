---
date: '2025-10-30T19:57:39-04:00'
draft: false
title: 'Caddy'
tags: 
  - 'Good Idea'
---

I have been using nginx for a while. I use it to serve static files, as a [layer 7 (HTTP) 
reverse proxy][0], and as a [layer 4 (TCP/UDP) reverse proxy][1]. It [automatically
acquires][2] SSL certificates from Let's Encrypt using `certbot` with the HTTP-01 challenge.

That's how it's supposed to work, at least. 

It generally does exactly that, but there are some rough edges that I have to work around. 
Like how I have to maintain a script to get certbot working for all subdomains. 
Or that it uses the HTTP-01 challenge, and it's not simple to change it to use DNS-01. 
Or that it doesn't seem to reload the new certificate, so I have to restart the service
every seven days. The configuration language, while relatively simple, doesn't 
have the most common defaults, so I end up copy-pasting the "one good config"
over and over for different sites.

[Caddy][4] solves these problems for me. It supports [L7 reverse proxying out-of-the-box][5], 
L4 reverse proxying with [a plugin][3], [HTTP-01][6] and [DNS-01][7] challenges for automatic TLS,
and it has a [simple configuration format][8]. 

I am usually pretty conservative about adopting new tools because I like to keep
it simple and reduce maintenance churn. When a friend told me about Caddy while I 
was griping about my nginx setup, I dismissed it. I put too many hours into setting
up nginx years ago, and my yearly maintenance budget for this bit of home-lab was 
0 hours. I didn't have the time to learn a new tool. However, when I learned about 
the automatic TLS feature, I started to come around. 
Unfortunately, Caddy didn't yet support DNS-01 challenges when your nameservers 
were hosted in Linode, so I had to pick up maintainer duties on the [caddy-dns-linode][9] 
[plugin][10]. A bit of refactoring and integration testing later, DNS-01 challenges 
are now supported on Linode nameservers.

It also has this cool retro [hit counter][11] [plugin][12] which works as part of 
the built-in templating engine. You can see it on the bottom of this page. I 
think it adds a great bit of flair to my site and reminds me of older websites. 
It really increments for each visitor.

I just want to say again how awesome the automatic TLS feature is. It's so easy 
that there is no excuse not to use it. With DNS-01, I can even get wildcard certificates
on my non-publicly-accessible servers, like my "[home portal][13]" accessible only from
my home network.

In closing, I'm liking Caddy so far.

[0]: https://github.com/HugoKlepsch/reverse-proxy/blob/ce9616b480e8a9d736ddb1f01077bad1888e9863/config/conf.d/sites-available/gitlab.conf
[1]: https://github.com/HugoKlepsch/reverse-proxy/blob/fe4e1197d478593d22c78d1c90a3a3c330727118/config/conf.d/stream/sites-available/gitlab-ssh.conf
[2]: https://github.com/HugoKlepsch/reverse-proxy/blob/a886da8e090e3c99b5736be660d0534dceb35e22/init-letsencrypt.sh#L8
[3]: https://github.com/mholt/caddy-l4
[4]: https://caddyserver.com/
[5]: https://caddyserver.com/docs/caddyfile/patterns#reverse-proxy
[6]: https://caddyserver.com/docs/automatic-https#http-challenge
[7]: https://caddyserver.com/docs/automatic-https#dns-challenge
[8]: https://caddyserver.com/docs/caddyfile-tutorial
[9]: https://github.com/caddy-dns/linode
[10]: https://caddyserver.com/docs/modules/dns.providers.linode
[11]: https://github.com/mholt/caddy-hitcounter
[12]: https://caddyserver.com/docs/modules/http.handlers.templates.functions.hitCounter
[13]: https://github.com/HugoKlepsch/home-portal