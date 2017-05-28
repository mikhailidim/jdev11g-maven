#!/bin/bash 

# Configure environment
FMW_DEF=${1:-/u01/app/oracle/fmw}
if [ $# -eq "0" ]; then
    read -e -p "Please specify your Middleware home [$FMW_DEF]:" FMW_HOME
fi
export TMP=${TMP:-/tmp}
export FMW_HOME=${FMW_HOME:-$FMW_DEF}
export ORACLE_HOME=$FMW_HOME/jdeveloper
export MVN_HOME=$ORACLE_HOME/apache-maven-2.1.0
export WLS_HOME=$FMW_HOME/wlserver_10.3
export JAVA_HOME=$FMW_HOME/jdk160_24
LOG=./wls-maven-conf.log

echo -e "\nEnvironment Configuration" |tee $LOG
echo ORACLE_HOME=$ORACLE_HOME |tee -a $LOG
echo JAVA_HOME=$JAVA_HOME |tee -a $LOG
echo MVN_HOME=$MVN_HOME |tee -a $LOG
echo TEMP=$TMP/wlmaven
echo -e "\n-------------------------------------"
$JAVA_HOME/bin/java -version |tee -a $LOG
$MVN_HOME/bin/mvn -version |tee -a $LOG


echo -e "\nPrepare plugin" |tee -a $LOG

pushd . >/dev/null

mkdir $TMP/wlmaven
cp wls-pom.xml $TMP/wlmaven/pom.xml

cd $WLS_HOME/server/lib/
$JAVA_HOME/bin/java -jar $WLS_HOME/server/lib/wljarbuilder.jar -profile weblogic-maven-plugin |tee -a $LOG
mv weblogic-maven-plugin.jar $TMP/wlmaven

cd $TMP/wlmaven


echo -e "\nInstall Weblogic Related libraries" |tee -a >> $LOG
$MVN_HOME/bin/mvn install:install-file -DgroupId=com.oracle.cryptoj -DartifactId=cryptoj -Dversion=1.0 -Dpackaging=jar -Dfile=$FMW_HOME/modules/cryptoj.jar -DgeneratePom=true |tee -a $LOG
$MVN_HOME/bin/mvn install:install-file -DgroupId=weblogic -DartifactId=weblogic -Dversion=10.3.6 -Dpackaging=jar -Dfile=$WLS_HOME/server/lib/weblogic.jar  |tee -a $LOG
$MVN_HOME/bin/mvn install:install-file -DgroupId=weblogic -DartifactId=weblogic -Dversion=10.3.6  -Dpackaging=jar -Dfile=$WLS_HOME/server/lib/wlfullclient.jar  |tee -a $LOG
$MVN_HOME/bin/mvn install:install-file -DgroupId=weblogic -DartifactId=webservices -Dversion=10.3.6  -Dpackaging=jar -Dfile=$WLS_HOME/server/lib/webservices.jar  |tee -a $LOG

echo -e "\nInstall SOA Runtime helpers" |tee -a $LOG
call $MVN_HOME/bin/mvn install:install-file -DgroupId=oracle.soa.utils -DartifactId=common -Dversion=11.1  -Dpackaging=jar -Dfile=$ORACLE_HOME/soa/modules/oracle.soa.fabric_11.1.1/fabric-runtime.jar  -DgeneratePom=true |tee -a $LOG


echo -e "\nInstall maven plugin"  |tee -a $LOG
$MVN_HOME/bin/mvn install:install-file -Dfile=weblogic-maven-plugin.jar -DpomFile=pom.xml  |tee -a $LOG

popd 

#Clean up
rm -rf $TMP/wlmaven

#Validate configuration 
echo -e "\nTest Weblogic plugin"  |tee -a $LOG
$MVN_HOME/bin/mvn  weblogic:help |tee -a $LOG

