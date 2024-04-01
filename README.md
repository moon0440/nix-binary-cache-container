# Nix Binary Cache Container

This project sets up a containerized Nix binary cache using Nginx as a reverse proxy. It caches Nix packages to speed up build times and reduce bandwidth usage by serving packages from a local cache before falling back to the official Nix package cache.

## Features

- **Nginx Reverse Proxy**: Utilizes Nginx to cache and serve Nix packages.
- **Customizable Nix Build**: A Nix expression to build the Docker image with Nginx and the necessary configurations.
- **CI/CD Integration**: Includes GitHub Actions workflow for automatic build and push of the Docker image to GitHub Container Registry (GHCR).

## Project Structure
- `nginx.conf` - Nginx configuration file to setup the reverse proxy and caching behavior.
- `nix-cache.nix` - Nix expression for building the Docker image.

## Getting Started

### Prerequisites

- Docker
- Nix package manager

### Building and Running

1. Clone this repository.
2. Run the `build.sh` script to build and start the Nix binary cache container:
   ```bash
   ./build.sh 
   ```

1. The Nix binary cache is now running on port 80 and caching packages to ./pkgcache.

Configuration

- Nginx: Customize nginx.conf as needed. By default, it caches successful responses and serves them with appropriate cache headers.
- Nix: Adjust nix-cache.nix for different Nginx configurations or to add additional packages to the Docker image.

Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.

License

This project is licensed under the [MIT License]().

Acknowledgments

- NixOS community for the Nix package manager.
- Nginx for the powerful reverse proxy and caching capabilities.

