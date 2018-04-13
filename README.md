# Create a custom image for IOT deployment #

In the following article, it will be presented how to create a custom image for IOT deployment. 

# STEPS 

## 1. Create build environment ##

[Read the general manual](https://docs.armbian.com/Developer-Guide_Build-Preparation/).

## 2. Copy userpatches/ over to build environment ##

- customize username, hostname and add your public ssh key needed to login
- disable console root login with password 1234 (optional)  

## 3. Build image with the following command ##

- add LIB_TAG="development" to config-default.conf (currently needed)

		./compile.sh KERNEL_CONFIGURE="no" KERNEL_ONLY="no" BOARD="orangepizero" BRANCH="next" RELEASE="xenial" BUILD_DESKTOP="no"
