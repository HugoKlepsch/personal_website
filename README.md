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

# Build

To build the docker image, run 
`docker compose -f compose/docker-compose.yml build`.

To generate the static site, run `./build.sh`, which runs `hugo` in the 
`hugo-site` directory using a docker container.

# Making posts

All changes to the blog are made in the `hugo-site` directory.

To add a new post, run `hugo new content content/my-post.md`. To use the 
"good_idea" archetype, run `hugo new content --kind good_idea content/my-good-idea-post.md`.

Archetypes are defined in `archetypes`.
