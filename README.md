# Personal Website

This project sets up an Nginx server to serve static files. The reverse proxy 
points to port 5060 on this machine, with TLS termination handled by the 
remote reverse proxy. Traffic from reverse proxy to here goes via a VPN tunnel.

## Configuration

The Nginx configuration files are located in the `config` directory.
- Main configuration: `config/nginx.conf`
- Site configuration: `config/conf.d/default.conf`

