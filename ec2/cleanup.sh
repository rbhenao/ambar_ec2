#!/bin/bash

#Run this script to clean up all of the ambar docker containers and ambar directories

#clean the docker containers, volumes and networks
echo -e "Cleaning Docker containers, volumes, and networks\n"
echo "Running docker container prune.."
docker container prune

echo -e "\nRunning docker volume prune.."
docker volume prune

echo -e "\nRunning docker network prune.."
docker network prune

echo -e "\nRunning image prune.."
docker image prune
docker image prune -a # Clean dangling images as well

echo -e "\nRunning builder prune.."
docker builder prune

# Function to clean out the ambar directories
clean_directory() {
    local ambar_directory_to_clean=$1

    # Check if the directory exists and has files to remove
    if [ -d "$ambar_directory_to_clean" ]; then
        
        if [ "$(ls -A "$ambar_directory_to_clean")" ]; then
            # List the files in the directory
            echo "  Files and dirs in $ambar_directory_to_clean:"
            ls -a "$ambar_directory_to_clean"

            # Ask for confirmation
            read -p "  Delete all files from $ambar_directory_to_clean? This cannot be undone! (y/n) " answer

            # Check the user's response
            if [[ $answer == [Yy] ]]; then
                # Proceed with removal
                if [ "$ambar_directory_to_clean" != "/" ]; then
                    sudo find "$ambar_directory_to_clean" -mindepth 1 -maxdepth 1 -name '.*' -exec rm -rvf {} +
                    sudo rm -rvf "$ambar_directory_to_clean"/*
                    echo -e "  All files and dirs from $ambar_directory_to_clean removed.\n"
                else 
                    echo "Error: Trying to clean root!! Aborting."
                fi
            elif [[ $answer == [Nn] ]]; then
                # Do nothing, exit script
                echo "  No files were removed."
            else
                # Invalid input
                echo -e "  Invalid input. No files were removed.\n"
            fi
        else
            echo -e "  No files to clean in $ambar_directory_to_clean\n"
        fi
    else
        echo -e "  Directory $ambar_directory_to_clean does not exist.\n"
    fi
}

# Ask the user for the directory path
echo -e "\nCleaning Ambar dirs"

# Set a default value if the input is empty
ambar_directory_to_clean="/opt/ambar"

# Call the function for each subdirectory
clean_directory "${ambar_directory_to_clean}/data"
clean_directory "${ambar_directory_to_clean}/intake"