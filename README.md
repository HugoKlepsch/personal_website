# Personal Website

---

# Purpose

Host my personal website.

# High level design

This project sets up a web server to serve static files. The reverse proxy 
points to port 5060 on this machine, with TLS termination handled by the 
remote reverse proxy. Traffic from reverse proxy to here goes via a VPN tunnel.

* My blog is hosted under `/blog/`.

* Files hosted under `/public/` are publicly accessible and directory listing is 
enabled.

* Files hosted under `/unlisted/` are publicly accessible and directory listing is 
disabled.

# Technologies

* [Docker Compose](https://docs.docker.com/compose/)
* [Caddy](https://github.com/caddyserver/caddy)

# Configuration

* Caddy configuration is in `Caddyfile`