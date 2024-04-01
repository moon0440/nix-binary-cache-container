docker stop ncp
docker rmi ncp:latest
rm -f result
sudo rm -rf pkgcache
sed -i '/^substituters =/s/^/#/' ~/.config/nix/nix.conf
nix-build --check nix-cache.nix
nix-build nix-cache.nix
docker load < result
mkdir pkgcache
sed -i '/^#substituters =/s/^#//' ~/.config/nix/nix.conf
docker run -p 80:80 -v ./pkgcache:/var/pkgcache --rm -it --name ncp ncp:latest
 # docker run -p 80:80 -v pkgcache:/var/pkgcache --rm -d --name ncp ncp:latest 
