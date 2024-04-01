{ pkgs ? import <nixpkgs> {} }:

let
  nginxPort = "80";
  # nginxConf = pkgs.writeTextFile {
  #   name = "nginx-proxy-config";
  #   destination = "nginx.conf";
  #   text= builtins.readFile ./nginx.conf;
  # };
  nginxConf = pkgs.writeTextFile {
    name="ncp-nginx-conf";
    text = builtins.readFile ./nginx.conf;
  };
  #   user nobody nobody;
  #   daemon off;
  #   worker_processes 1;
  #   
  #   error_log /var/log/nginx/error.log warn;
  #   pid /dev/null;
  #   
  #   events {
  #     worker_connections 1024;
  #   }
  #   
  #   http {
  #     sendfile on;
  #     tcp_nopush on;
  #     tcp_nodelay on;
  #     keepalive_timeout 65;
  #     types_hash_max_size 2048;
  #   
  #     #include /etc/nginx/mime.types;
  #     default_type application/octet-stream;
  #   
  #     access_log /dev/stdout;
  #     error_log /dev/stdout info; 
  #   
  #     gzip on;
  #   
  #     proxy_cache_path /var/pkgcache keys_zone=cache_zone:100m max_size=20g inactive=365d;
  #     # proxy_cache_path /var/pkgcache keys_zone=cache_zone:100m max_size=20g inactive=365d use_temp_path=off;
  #     proxy_cache cache_zone;
  #     proxy_cache_valid 200 365d;
  #     proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_504 http_403 http_404 http_429;
  #     proxy_ignore_headers X-Accel-Expires Expires Cache-Control Set-Cookie;
  #     proxy_cache_lock on;
  #     resolver 8.8.8.8 ipv6=off;
  #
  #
  #     # proxy_ssl_server_name on;
  #     #proxy_ssl_verify on;
  #     # proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
  #     server {
  #       listen 80;
  #       server_name _;    
  #
  #       location / {
  #         proxy_set_header Host $proxy_host;
  #         proxy_pass https://cache.nixos.org;
  #       }
  #     }
  # '';

  ncpImage = pkgs.dockerTools.buildLayeredImage {
    name = "ncp";
    tag = "latest";
    created = "now";
    contents = [ 
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.nginx
      pkgs.dockerTools.fakeNss
    ];
  
    fakeRootCommands = ''
      mkdir -p /var/pkgcache /var/public-nix-cache
      chown nobody:nobody /var/pkgcache /var/public-nix-cache
    '';
  
    extraCommands = ''
      mkdir -p tmp/nginx_client_body
  
      # nginx still tries to read this directory even if error_log
      # directive is specifying another file :/
      mkdir -p var/log/nginx
    ''; 
  
    config = {
      Cmd = [ "nginx" "-c" nginxConf ]; # Correct syntax for CMD array format
      ExposedPorts = {
        "${nginxPort}/tcp" = {}; # Use nginxPort variable
      };
      Volumes = {
        "/var/pkgcache" = {}; # Ensure this volume is correctly defined
      };
    };
  };
in ncpImage
