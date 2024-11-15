run-docker-env() {
  if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and ensure the service is running."
    return 1
  fi

  # Check if Docker daemon is running
  if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start the Docker service."
    return 1
  fi

  local repository="ra4ing/pwn"  # Modify this to your Docker Hub repository name
  local image

  # Check if a tag was provided as an argument
  if [ -n "$1" ]; then
    image="$repository:$1"
    echo "Starting Docker container with tag $1..."
  else
    # Fetch tags if no argument provided
    echo "Fetching available tags for $repository..."
    local tags=$(curl -s "https://hub.docker.com/v2/repositories/$repository/tags/" | jq -r '."results"[].name')

    if [ -z "$tags" ]; then
      echo "Failed to fetch tags or no tags available."
      return 1
    fi

    echo "Available tags:"
    local count=1
    local tag_array=()
    for tag in $tags; do
      echo "$count) $tag"
      tag_array+=("$tag")
      ((count++))
    done

    echo -n "Please choose a tag (enter the number): "
    read tag_choice

    local selected_tag=${tag_array[$tag_choice-1]}
    if [ -z "$selected_tag" ]; then
      echo "Invalid choice"
      return 1
    fi

    image="$repository:$selected_tag"
    echo "Starting Docker container with tag $selected_tag..."
  fi

  # Check if the image exists locally
  if ! docker image inspect "$image" &>/dev/null; then
    echo "Image $image not found locally. Pulling from Docker Hub..."
    docker pull "$image"
  fi

  # Run the Docker container
  docker run -it --rm -v "${PWD// /\\ }:/home/ra4ing/hacker" --privileged "$image"
}
