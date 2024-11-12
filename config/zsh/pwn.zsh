run_docker_env() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: run_ubuntu <version>"
    return 1
  fi

  local supported_versions=("16" "18" "20" "22" "23" "24")

  if [[ ! " ${supported_versions[@]} " =~ " $1 " ]]; then
    echo "Unsupported Ubuntu version. Supported versions are: ${supported_versions[*]}"
    return 1
  fi

  local version=$1
  local image="ra4ing/pwn:ubuntu$version"

  echo "Starting Docker container with Ubuntu $version..."
  docker run -it --rm -v "$PWD:$HOME/work" --privileged "$image"
}
