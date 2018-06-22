#!/usr/bin/env fish

function __enter_container_id -d "Enter container with provided id"
  set selected_container $argv
  if docker exec "$selected_container" fish >/dev/null
    docker exec -it "$selected_container" fish
  else if docker exec "$selected_container" zsh >/dev/null
    docker exec -it "$selected_container" zsh
  else if docker exec "$selected_container" bash >/dev/null
    docker exec -it "$selected_container" bash
  else
    docker exec -it "$selected_container" sh
  end
end


function __enter_check_tools -d "Check if all necessary cli tools are installed"
  if not type -q docker
     echo "Docker not installed"
     return 1
  end

  if not type -q fzf
     echo "fzf not installed"
     return 1
  end
  return 0
end

function __enter_select_container -d "Select container via fzf"
  docker ps --filter status=running --format "table {{.Names}}\t{{.Image}}\t{{.ID}}" | awk 'NR > 1 { print }' | sort | read -z containers
  if [ -z "$containers" ];
      echo -e "No running container found"
      return 0
  end
  printf $containers | fzf -e --reverse | awk '{ print $3 }' | read selected_container; or return 1
  printf $selected_container
end


function enter -d "Interactively try to enter a docker container"
  __enter_check_tools; or return 1
  set selected_container (__enter_select_container); or return 1
  __enter_container_id $selected_container; or return 1
end
