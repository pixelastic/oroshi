# echo "???"
# All images
function _complete_docker_images_all {
  reply=($(dil-raw))
}
compctl -K _complete_docker_images_all diR

# # All containers
# function _complete_docker_containers_all {
#   reply=($(dcl-raw))
# }
# compctl -K _complete_docker_containers_all dcR

# # Running containers
# function _complete_docker_containers_running {
#   reply=($(dcl-raw --running))
# }
# compctl -K _complete_docker_containers_running dcsto dcc

# # Stopped containers
# function _complete_docker_containers_stopped {
#   reply=($(dcl-raw --running))
# }
# compctl -K _complete_docker_containers_stopped dcsta


