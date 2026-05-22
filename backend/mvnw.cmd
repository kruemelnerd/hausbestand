@ECHO OFF
SETLOCAL

SET MAVEN_USER_HOME=%MAVEN_USER_HOME%
IF "%MAVEN_USER_HOME%"=="" SET MAVEN_USER_HOME=%USERPROFILE%\.m2

IF NOT EXIST "%~dp0.mvn\wrapper\maven-wrapper.properties" (
  ECHO Missing Maven wrapper properties.& EXIT /B 1
)

FOR /F "tokens=1,* delims==" %%A IN ('findstr /B distributionUrl "%~dp0.mvn\wrapper\maven-wrapper.properties"') DO SET DIST_URL=%%B
IF "%DIST_URL%"=="" (
  ECHO Missing distributionUrl.& EXIT /B 1
)

IF EXIST "%MAVEN_USER_HOME%\wrapper\dists\apache-maven" (
  REM Use existing Maven distribution if present.
)

IF EXIST "%ProgramFiles%\Apache\maven\bin\mvn.cmd" (
  CALL "%ProgramFiles%\Apache\maven\bin\mvn.cmd" %*
  EXIT /B %ERRORLEVEL%
)

ECHO This lightweight wrapper is intended for Unix-like environments. Please install Maven or use WSL.
EXIT /B 1
