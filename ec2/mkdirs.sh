#!/bin/bash

ambar_dir="/opt/ambar"

echo "Creating $ambar_dir"
sudo mkdir $ambar_dir
sudo chown -R ${USER}: $ambar_dir


echo "Creating ${ambar_dir}/db"
mkdir /opt/ambar/db

echo "Creating ${ambar_dir}/rabbit"
mkdir /opt/ambar/rabbit

echo "Creating ${ambar_dir}/data"
mkdir /opt/ambar/data