@SET ECHO OFF
REM Configure environment
SET FMW_HOME=C:\Oracle\Middleware
SET ORACLE_HOME=%FMW_HOME%\JDeveloper
SET MVN_HOME=%ORACLE_HOME%\apache-maven-2.1.0
SET WLS_HOME=%FMW_HOME%\wlserver_10.3
SET JAVA_HOME=%FMW_HOME%\jdk160_24
SET LOG=%~dp0\wls-maven-conf.log
ECHO "Prepare plugin" >%LOG%
pushd .

mkdir %TMP%\wlmaven
copy wls-pom.xml %TMP%\wlmaven\pom.xml

cd %WLS_HOME%\server\lib\
%JAVA_HOME%\bin\java -jar %WLS_HOME%\server\lib\wljarbuilder.jar -profile weblogic-maven-plugin >> %LOG% 2>&1
move weblogic-maven-plugin.jar %TMP%\wlmaven

cd %TMP%\wlmaven

ECHO "Install Weblogic Related libraries" >> %LOG%
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=com.oracle.cryptoj -DartifactId=cryptoj -Dversion=1.0 -Dpackaging=jar -Dfile=%FMW_HOME%\modules\cryptoj.jar -DgeneratePom=true >> %LOG% 2>&1
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=weblogic -DartifactId=weblogic -Dversion=10.3.6 -Dpackaging=jar -Dfile=%WLS_HOME%\server\lib\weblogic.jar  >> %LOG% 2>&1
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=weblogic -DartifactId=weblogic -Dversion=10.3.6  -Dpackaging=jar -Dfile=%WLS_HOME%\server\lib\wlfullclient.jar  >> %LOG% 2>&1
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=weblogic -DartifactId=webservices -Dversion=10.3.6  -Dpackaging=jar -Dfile=%WLS_HOME%\server\lib\webservices.jar  >> %LOG% 2>&1

ECHO "Install SOA Runtime helpers " >> %LOG%
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=oracle.soa.utils -DartifactId=common -Dversion=11.1  -Dpackaging=jar -Dfile=%ORACLE_HOME%\soa\modules\oracle.soa.fabric_11.1.1\fabric-runtime.jar  -DgeneratePom=true >> %LOG% 2>&1
call %MVN_HOME%\bin\mvn install:install-file -DgroupId=oracle.xml -DartifactId=parser.v2 -Dversion=11.1  -Dpackaging=jar -Dfile=%FMW_HOME%\oracle_common\modules\oracle.xdk_11.1.0\xmlparserv2.jar  -DgeneratePom=true >> %LOG% 2>&1


ECHO "Install maven plugin"  >> %LOG% 2>&1
call %MVN_HOME%\bin\mvn install:install-file -Dfile=weblogic-maven-plugin.jar -DpomFile=pom.xml  >> %LOG% 2>&1

popd 

REM Clean up
rmdir /S/Q %TMP%\wlmaven

REM Validate configuration 
%MVN_HOME%\bin\mvn  weblogic:help 

