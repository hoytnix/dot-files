#!/bin/bash
# ----------
# Docker management

case $1 in
    "ip")
        echo "Container IP:"
        docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$1" 
        ;;
    "run")
        # TODO: PID file.
        echo "Running container:"
        docker run "$1" .
        ;;
    "build")
        echo "Building container:"
        docker build -t "$1" .
        ;;
    "ls")
        echo "Docker images:"
        docker images
        ;;
    "pull")
        echo "Pulling image:"
        docker pull "$1"
        ;;
    *)
        echo "Unknown command."
        ;;
esac

exit 0
    # Docker PID file

