@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

REM === SETTINGS ===
set PASSPHRASE=1234

REM === ASK USER FOR DOMAIN ===
set /p DOMAIN=Enter your domain (e.g. example.com): 

if "%DOMAIN%"=="" (
    echo [ERROR] No domain provided.
    pause
    exit /b 1
)

echo.
echo [INFO] Using domain: %DOMAIN%
set CN=www.%DOMAIN%
set EMAIL=info@%DOMAIN%

REM === CERT SUBJECT INFO ===
set COUNTRY=CA
set STATE=Ontario
set LOCALITY=Toronto
set ORG=ACME
set ORG_UNIT=IT

REM === CLEANUP OLD FILES (OPTIONAL) ===
del CAPrivate.* >nul 2>&1
del MyPrivate.key >nul 2>&1
del MyRequest.csr >nul 2>&1
del MyCert.crt >nul 2>&1
del openssl.ss.cnf >nul 2>&1
del installation.txt >nul 2>&1

REM === STEP 1: Create CA Private Key ===
echo.
echo [STEP 1] Generating CA private key...
openssl genrsa -des3 -passout pass:%PASSPHRASE% -out CAPrivate.key 2048

REM === STEP 2: Create CA Certificate ===
echo.
echo [STEP 2] Creating CA certificate...
openssl req -x509 -new -key CAPrivate.key -sha256 -days 3650 ^
-out CAPrivate.pem -passin pass:%PASSPHRASE% ^
-subj "/C=%COUNTRY%/ST=%STATE%/L=%LOCALITY%/O=%ORG%/OU=%ORG_UNIT%/CN=%CN%/emailAddress=%EMAIL%"

REM === STEP 3: Convert PEM to CRT ===
echo.
echo [STEP 3] Exporting CA public cert...
openssl x509 -outform PEM -in CAPrivate.pem -out CAPrivate.crt

REM === STEP 4: Create Server Private Key ===
echo.
echo [STEP 4] Creating server private key...
openssl genrsa -passout pass:%PASSPHRASE% -out MyPrivate.key 2048

REM === STEP 5: Create CSR ===
echo.
echo [STEP 5] Generating CSR...
openssl req -new -key MyPrivate.key -out MyRequest.csr -passin pass:%PASSPHRASE% ^
-subj "/C=%COUNTRY%/ST=%STATE%/L=%LOCALITY%/O=%ORG%/OU=%ORG_UNIT%/CN=%CN%/emailAddress=%EMAIL%"

REM === STEP 6: Create Extension Config File ===
echo.
echo [STEP 6] Creating SAN config...
(
echo basicConstraints = CA:FALSE
echo subjectAltName = DNS:www.%DOMAIN%,DNS:*.%DOMAIN%
echo extendedKeyUsage = serverAuth
) > openssl.ss.cnf

REM === STEP 7: Sign CSR to Create Certificate ===
echo.
echo [STEP 7] Signing certificate...
openssl x509 -req -in MyRequest.csr -CA CAPrivate.pem -CAkey CAPrivate.key -extfile openssl.ss.cnf ^
-out MyCert.crt -days 3650 -sha256 -passin pass:%PASSPHRASE%

REM === STEP 8: Create Installation Instructions ===
echo.
echo [STEP 8] Creating installation.txt...

REM Define a function to output the installation instructions
call :generate_instructions > installation.txt

REM Append the certificate content (without displaying it in the console)
type CAPrivate.crt | findstr /V "CERTIFICATE" >> installation.txt

REM Append the certificate footer
echo -----END CERTIFICATE----- >> installation.txt

echo.
echo [OK] All done.
echo.
echo [KEY] Password used for private keys: 1234
echo.
echo [FILE] Installation file: installation.txt
echo.
pause
exit /b 0

:generate_instructions
echo ===============================================================
echo Installation Instructions for %DOMAIN%
echo ===============================================================
echo.
echo 1. Install CA Certificate into Windows Trusted Root Store:
echo    - Open 'Manage user certificates'
echo    - Navigate to 'Trusted Root Certification Authorities'
echo    - Import CAPrivate.crt
echo.
echo 2. For XAMPP:
echo    - Create these folders:
echo        * C:\xampp\apache\conf\certs\my-project
echo        * C:\xampp\htdocs\my-project
echo.
echo    - Copy these files to C:\xampp\apache\conf\certs\my-project:
echo        * MyCert.crt
echo        * MyPrivate.key
echo        * CAPrivate.crt
echo.
echo    - Configure virtual hosts in C:\xampp\apache\conf\extra\httpd-vhosts.conf:
echo.
echo        # HTTP VirtualHost (Port 80)
echo        ^<VirtualHost *:80^>
echo            DocumentRoot "C:/xampp/htdocs/my-project"
echo            ServerName example.com
echo            ServerAlias www.example.com
echo            ^<Directory "C:/xampp/htdocs/my-project"^>
echo                Options Indexes FollowSymLinks MultiViews
echo                AllowOverride All
echo                Require all granted
echo            ^</Directory^>
echo        ^</VirtualHost^>
echo.
echo        # HTTPS VirtualHost (Port 443)
echo        ^<VirtualHost *:443^>
echo            DocumentRoot "C:/xampp/htdocs/my-project"
echo            ServerName example.com
echo            ServerAlias www.example.com
echo            SSLEngine on
echo            SSLCertificateFile "conf/certs/my-project/MyCert.crt"
echo            SSLCertificateKeyFile "conf/certs/my-project/MyPrivate.key"
echo            SSLCertificateChainFile "conf/certs/my-project/CAPrivate.crt"
echo            ^<Directory "C:/xampp/htdocs/my-project"^>
echo                Options Indexes FollowSymLinks MultiViews
echo                AllowOverride All
echo                Require all granted
echo            ^</Directory^>
echo        ^</VirtualHost^>
echo.
echo    - Edit php.ini:
echo        openssl.cafile="C:\xampp\apache\bin\curl-ca-bundle.crt"
echo.
echo    - Append the following certificate to curl-ca-bundle.crt:
echo.
echo %DOMAIN%
echo ============================
echo.
echo -----BEGIN CERTIFICATE-----
exit /b 0
