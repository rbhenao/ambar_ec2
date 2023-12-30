#!/bin/bash

ambar_dir="/opt/ambar"

echo "Creating $ambar_dir"
sudo mkdir $ambar_dir
sudo chown -R ${USER}: $ambar_dir


echo "Creating ${ambar_dir}/data"
mkdir /opt/ambar/data

echo "Creating ${ambar_dir}/intake"
mkdir /opt/ambar/intake