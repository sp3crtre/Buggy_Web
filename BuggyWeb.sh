#!/bin/bash

select_docker_image() {
  docker_images=("santosomar/gravemind" "santosomar/dc30_01:latest" "santosomar/dc31_01:latest" "santosomar/dvna" "santosomar/ywing:latest" "santosomar/hackme-rtov" "santosomar/mayhem" "santosomar/dc31_03:latest" "santosomar/dvwa" "santosomar/dc31_02:latest" "santosomar/dc30_02:latest" "santosomar/juice-shop")

  echo "Select a Docker image to run:"
  for i in "${!docker_images[@]}"; do
    echo "($((i+1))) ${docker_images[$i]}"
  done

  read -p "Enter the number corresponding to the Docker image: " choice

  if [[ ! $choice =~ ^[1-9]|10|11|12$ ]]; then
    echo "Invalid choice. Exiting."
    exit 1
  fi

  selected_image="${docker_images[choice-1]}"
  docker run -d "$selected_image"

}

terminate_all_containers() {
  echo "Terminating all running Docker containers..."
  docker stop $(docker ps -q)
  echo "All running Docker containers terminated."

}

clear
echo "                                                                                    
@@@@@@@   @@@  @@@   @@@@@@@@   @@@@@@@@  @@@ @@@     @@@  @@@  @@@  @@@@@@   @@@@@@@   
@@@@@@@@  @@@  @@@  @@@@@@@@@  @@@@@@@@@  @@@ @@@     @@@  @@@  @@@  @@@@@@@  @@@@@@@@  
@@!  @@@  @@!  @@@  !@@        !@@        @@! !@@     @@!  @@!  @@!      @@@  @@!  @@@  
!@   @!@  !@!  @!@  !@!        !@!        !@! @!!     !@!  !@!  !@!      @!@  !@   @!@  
@!@!@!@   @!@  !@!  !@! @!@!@  !@! @!@!@   !@!@!      @!!  !!@  @!@  @!@!!@   @!@!@!@   
!!!@!!!!  !@!  !!!  !!! !!@!!  !!! !!@!!    @!!!      !@!  !!!  !@!  !!@!@!   !!!@!!!!  
!!:  !!!  !!:  !!!  :!!   !!:  :!!   !!:    !!:       !!:  !!:  !!:      !!:  !!:  !!!  
:!:  !:!  :!:  !:!  :!:   !::  :!:   !::    :!:       :!:  :!:  :!:      :!:  :!:  !:!  
 :: ::::  ::::: ::   ::: ::::   ::: ::::     ::        :::: :: :::   :: ::::   :: ::::  
:: : ::    : :  :    :: :: :    :: :: :      :          :: :  : :     : : :   :: : ::   

Author: Kaizer Baynosa | Spectre  
Credits to the original author for the base code used in this script.

1. Run a Docker image
2. Terminate all running Docker containers
3. Install all Testing Lab
4. Exit
"

read -p "[+] Choose an option above: " menu_choice

case $menu_choice in
  1)
    select_docker_image
    ;;
  2)
    terminate_all_containers
    ;;
  3) 
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

    # installing hostapd
    apt install hostapd

    #Installing tor
    apt install -y tor

    #Installing certspy
    pip3 install certspy

    #Installing Jupyter Notebooks
    apt install -y jupyter-notebook

    #Installing EDB
    apt install -y edb-debugger

    # Installing NodeGoat
    # cloning the NodeGoat repo
    git clone https://github.com/OWASP/NodeGoat.git

    # replacing the docker-compose.yml file with my second bridge network (10.7.7.0/24)
    curl -sSL https://websploit.org/nodegoat-docker-compose.yml > /root/NodeGoat/docker-compose.yml

    # downloading the nodegoat.sh script from websploit
    # this will be used manually to setup the NodeGoat environment
    wget https://websploit.org/nodegoat.sh
    chmod 744 nodegoat.sh 

    # Installing Gorilla-CLI to be used in AI-related training
    pip3 install gorilla-cli

    #Getting the container info script
    sudo cd /root
    curl -sSL https://websploit.org/containers.sh > /root/containers.sh

    chmod +x /root/containers.sh
    mv /root/containers.sh /usr/local/bin/containers 

    #Final confirmation
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
