let
  nginxConfigFileOverlay = self: super: {
    nginx = super.nginx.overrideAttrs (oldAttrs: {
      postInstall = oldAttrs.postInstall or "" + ''
        mkdir -p $out/etc/nginx
        cp ${./nginx.conf} $out/etc/nginx/nginx.conf
      '';
    });
  };

  pkgs = import <nixpkgs> {
    overlays = [ nginxConfigFileOverlay ];
  };

  nginxPort = "80";

in pkgs.dockerTools.buildLayeredImage {
  name = "ncp";
  tag = "latest";
  created = "now";
  contents = [ 
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
    Cmd = [ "nginx" "-c" "/etc/nginx/nginx.conf" ];
    ExposedPorts = {
      "${nginxPort}/tcp" = {};
    };
    Volumes = {
      "/var/pkgcache" = {};
    };
  };
}

