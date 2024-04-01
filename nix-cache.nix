let
  nginxConfigTemplateFileOverlay = self: super: {
    nginx = super.nginx.overrideAttrs (oldAttrs: {
      postInstall = oldAttrs.postInstall or "" + ''
        mkdir -p $out/etc/nginx
        cp ${./nginx.conf.template} $out/etc/nginx/nginx.conf.template
      '';
    });
  };

  pkgs = import <nixpkgs> {
    overlays = [ nginxConfigTemplateFileOverlay ];
  };

  nginxPort = "80";
  nginxStartScript = pkgs.writeShellScriptBin "start-nginx" ''
      # Initialize PROXY_SSL_CONFIG variable
      PROXY_SSL_CONFIG="proxy_ssl_server_name off;"
      
      # Check if TRUSTED_CERTIFICATE environment variable is set
      if [ -n "$TRUSTED_CERTIFICATE" ]; then
        # If TRUSTED_CERTIFICATE is set, configure proxy_ssl_* directives
        PROXY_SSL_CONFIG="proxy_ssl_server_name on;
      proxy_ssl_verify on;
      proxy_ssl_trusted_certificate $TRUSTED_CERTIFICATE;"
      fi
      
      # Export PROXY_SSL_CONFIG so that envsubst can substitute it
      export PROXY_SSL_CONFIG
      
      # Replace placeholders in the nginx configuration template
      ${pkgs.envsubst}/bin/envsubst '$RESOLVER,$PROXY_SSL_CONFIG' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
      cat /etc/nginx/nginx.conf 
      # Start nginx
      ${pkgs.nginx}/bin/nginx -c '/etc/nginx/nginx.conf'

    '';

in pkgs.dockerTools.buildLayeredImage {
  name = "ncp";
  tag = "latest";
  created = "now";
  contents = [ 
    pkgs.coreutils
    pkgs.nginx
    pkgs.envsubst
    pkgs.dockerTools.fakeNss
    nginxStartScript
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
    Cmd = [ "${nginxStartScript}/bin/start-nginx" ];
    ExposedPorts = {
      "${nginxPort}/tcp" = {};
    };
    Volumes = {
      "/var/pkgcache" = {};
    };
  };
}

