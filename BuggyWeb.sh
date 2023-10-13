#!/bin/bash
RED='\033[0;31m'     # Red color
GREEN='\033[0;32m'   # Green color
RESET='\033[0m'      # Reset to default color

ASCII_ART="${RED}
@@@@@@@   @@@  @@@   @@@@@@@@   @@@@@@@@  @@@ @@@     @@@  @@@  @@@  @@@@@@   @@@@@@@   
@@@@@@@@  @@@  @@@  @@@@@@@@@  @@@@@@@@@  @@@ @@@     @@@  @@@  @@@  @@@@@@@  @@@@@@@@  
@@!  @@@  @@!  @@@  !@@        !@@        @@! !@@     @@!  @@!  @@!      @@@  @@!  @@@  
!@   @!@  !@!  @!@  !@!        !@!        !@! @!!     !@!  !@!  !@!      @!@  !@   @!@  
@!@!@!@   @!@  !@!  !@! @!@!@  !@! @!@!@   !@!@!      @!!  !!@  @!@  @!@!!@   @!@!@!@   
!!!@!!!!  !@!  !!!  !!! !!@!!  !!! !!@!!    @!!!      !@!  !!!  !@!  !!@!@!   !!!@!!!!  
!!:  !!!  !!:  !!!  :!!   !!:  :!!   !!:    !!:       !!:  !!:  !!:      !!:  !!:  !!!  
:!:  !:!  :!:  !:!  :!:   !::  :!:   !::    :!:       :!:  :!:  :!:      :!:  :!:  !:!  
::  ::::  ::::: ::   ::: ::::   ::: ::::     ::        :::: :: :::   :: ::::   :: ::::  
::  : ::    : :  :    :: :: :    :: :: :      :          :: :  : :     : : :   :: : :: 
${RESET}
Author: Kaizer Baynosa | Spectre  
Credits to the original author for the base code used in this script.
"

select_docker_image() {
  clear
  echo -e "$ASCII_ART"
  docker_images=("santosomar/gravemind" "santosomar/dc30_01:latest" "santosomar/dc31_01:latest" "santosomar/dvna" "santosomar/ywing:latest" "santosomar/hackme-rtov" "santosomar/mayhem" "santosomar/dc31_03:latest" "santosomar/dvwa" "santosomar/dc31_02:latest" "santosomar/dc30_02:latest" "santosomar/juice-shop")
  echo ""
  echo "Select a Docker image to run:"
  
  for i in "${!docker_images[@]}"; do
    echo "[$((i+1))] ${docker_images[$i]}"
  done

  echo ""
  read -p "Enter the number corresponding to the Docker image: " choice

  if [[ ! $choice =~ ^[1-9]|10|11|12$ ]]; then
    echo "Invalid choice. Exiting."
    exit 1
  fi

  selected_image="${docker_images[choice-1]}"
  container_id=$(docker run -d -P "$selected_image")

  container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
  container_port=$(docker port "$container_id" | cut -d'-' -f1)
  echo "Host: http://$container_ip:$container_port" | sed 's#/tcp##'
  echo ""
  echo "Happy Hacking"

}


terminate_all_containers() {
  clear
  echo -e "$ASCII_ART"
  echo "Terminating all running Docker containers..."
  docker stop $(docker ps -q)
  echo "All running Docker containers terminated."

}

clear
echo -e "$ASCII_ART"

echo -e "[1] ${GREEN}Run a Docker image${RESET}"
echo -e "[2] ${GREEN}Terminate all running Docker containers${RESET}"
echo -e "[3] ${GREEN}Install all Testing Lab${RESET}"
echo -e "[4] ${GREEN}Exit${RESET}"
echo ""
read -p "[+] Choose an option above: " menu_choice

case $menu_choice in
  1)
    select_docker_image
    ;;
  2)
    terminate_all_containers
    ;;
  3) 
    clear
    echo -e "$ASCII_ART"
    read -n 1 -s -r -p "Press any key to continue the setup..."

    echo " "

    cd ~/
    apt update
    apt install -y wget vim vim-python-jedi curl exuberant-ctags git ack-grep python3-pip
    pip3 install pep8 flake8 pyflakes isort yapf Flask

    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
    apt update
    apt remove docker docker-engine docker.io
    apt install -y docker-ce

    echo "Installing Updating Docker-Compose!"
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "getting docker-compose.yml from WebSploit.org"
    wget https://websploit.org/docker-compose.yml

    echo "Setting up the containers and internal bridge network"
    docker-compose -f docker-compose.yml up -d

    apt install hostapd

    apt install -y tor

    pip3 install certspy

    apt install -y jupyter-notebook

    apt install -y edb-debugger

    git clone https://github.com/OWASP/NodeGoat.git

    curl -sSL https://websploit.org/nodegoat-docker-compose.yml > /root/NodeGoat/docker-compose.yml

    wget https://websploit.org/nodegoat.sh
    chmod 744 nodegoat.sh 

    pip3 install gorilla-cli

    sudo cd /root
    curl -sSL https://websploit.org/containers.sh > /root/containers.sh

    chmod +x /root/containers.sh
    mv /root/containers.sh /usr/local/bin/containers 

    sudo /usr/local/bin/containers
    echo "Installation completed successfully. Happy hacking!"

    ;;
  4)
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac
