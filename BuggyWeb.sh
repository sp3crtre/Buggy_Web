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
source venv/bin/activate

select_docker_image() {
  clear
  echo -e "$ASCII_ART"
  docker_images=( "santosomar/gravemind" "santosomar/dc30_01:latest" "santosomar/hackme-rtov" 
                  "santosomar/mayhem" "santosomar/dc31_03:latest" "santosomar/dvwa" 
                  "santosomar/dc31_02:latest" "santosomar/dc30_02:latest" "santosomar/juice-shop"
  )

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

  if [ "$selected_image" == "santosomar/gravemind" ]; then
    container_id=$(docker run -d "$selected_image")
    
    container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
    container_ports=$(docker port "$container_id" | cut -d'-' -f1)

    echo "Host http://$container_ip"

  fi

  container_id=$(docker run -d -P "$selected_image")
  container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
  container_ports=$(docker port "$container_id" | cut -d'-' -f1)
  
  for port in $container_ports; do
    if [ "$port" != "22/tcp" ]; then
      echo "Host: http://$container_ip:$port" | sed 's#/tcp##'

    fi
  done

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

install_lab() {
  clear 
  echo -e "$ASCII_ART"
  read -n 1 -s -r -p "Press any key to continue the setup..."
  echo "Hi $(whoami), this will take a couple of minutes to install. Please be patient"
  echo " "

  apt update
  apt install -y wget vim vim-python-jedi curl exuberant-ctags git ack-grep python3-pip
  apt install python3.11-venv
  python3 -m venv buggyWeb
  source buggyWeb/bin/activate

  pip3 install pep8 flake8 pyflakes isort yapf Flask gorilla-cli

  if [ -f /etc/redhat-release ]; then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
    sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  elif [ -f /etc/debian_version ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    cat /etc/debian_version
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
    apt update
    apt install -y docker-ce

  elif [ -f /etc/SuSE-release ]; then 
    zypper install docker docker-compose docker-compose-switch
    zypper addrepo https://download.opensuse.org/repositories/devel:languages:python/15.5/devel:languages:python.repo zypper refresh
    zypper install docker python3-docker-compose

  elif [ -f /etc/arch-release ]; then
    pacman -Syu
    pacman -S docker -y 
    sudo pacman -S base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay -S docker

  else
      echo "Unknown Linux distribution"

  fi

  echo "Installing Updating Docker-Compose!"
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  echo "getting docker-compose.yml from WebSploit.org"
  wget https://websploit.orgdeactivate/docker-compose.yml

  echo "Setting up the containers and internal bridge network"
  docker-compose -f docker-compose.yml up -d

  apt install hostapd

  apt install -y jupyter-notebook

  apt install -y edb-debugger

  git clone https://github.com/OWASP/NodeGoat.git

  curl -sSL https://websploit.org/nodegoat-docker-compose.yml > /root/NodeGoat/docker-compose.yml

  wget https://websploit.org/nodegoat.sh
  chmod 744 nodegoat.sh 

  sudo cd /root
  curl -sSL https://websploit.org/containers.sh > /root/containers.sh

  chmod +x /root/containers.sh
  mv /root/containers.sh /usr/local/bin/containers 

  sudo /usr/local/bin/containers
  echo "Installation completed successfully. Happy hacking!"

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
    install_lab
    ;;
  4)
    deactivate
    echo "Exiting."
    exit 0
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac
