#!bin/bash

dnf update
dnf install nginx -y
systemctl enable --now nginx