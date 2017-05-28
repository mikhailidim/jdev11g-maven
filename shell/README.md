# Apache Maven Configuration Scripts

This folder contains configuration scripts and plugin template. Scripts automate library configuration, plugin cration and installation to the local M2 repository.  Folder contents:
* [wl-maven-conf.cmd](wl-maven-conf.cmd) - Windows CMD file
* [wl-maven-conf.sh](./wl-maven.conf.sh)  - Linux shell script 
* [wls-pom.xml](./wls-pom.xml)  -  Plugin configuration template. 

##Prerequsites 
1. Installed Oracle JDeveloper 11g. Scripts were tesed with the versio 11.1.1.7.0, for higher vrsions you may need review folder names for Apache Maven and  JDK.
2. Oracle JDeveloper should have Apache Maven extension installed. 

##How to use scripts
1. Clone repository or download script file for you target platform and plugin configuration template to some local folder.
2. Don't forget to change permissions for the linux platform
   $ __chmod u+x wl-maven-conf.sh__
3. Type command  for Linux: 
    -  $ ./wl-maven-config.sh [jdev-fmw-dir]
    For Windows:
	-  C>wl-maven-config.cmd [jdev-fmw-dir]
	Where  **jdev-fmw-dir** optional argument with the your Oracle Fusion Middleware Installation directory. Your SOA Studio is installed **${jdev-fmw-dir}**/jdeveloper
    If you ommit this parameter script will ask you to enter value.
4. After a while it will produce wls-maven-config.log 
	

