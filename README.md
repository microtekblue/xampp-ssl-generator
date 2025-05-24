# XAMPP-SSL-GENERATOR
A Windows batch script that automates the creation of SSL certificates for local XAMPP development environments. This tool simplifies the process of setting up HTTPS for local development by generating a wildcard certificate that works for all subdomains, providing detailed installation instructions, and configuring Apache virtual hosts.

# SSL Certificate Generator for Windows Development

This repository contains a Windows batch script (`create_certs.bat`) that automates the creation of SSL certificates for local development environments, specifically designed for use with XAMPP on Windows.

## Purpose

When developing web applications locally, you often need HTTPS for:
- Testing secure features
- Avoiding mixed content warnings
- Using modern web APIs that require secure contexts
- Simulating production environments

This script creates a local Certificate Authority (CA) and signed SSL certificates that can be used with your local development server.

## Prerequisites

- Windows operating system
- OpenSSL installed and available in your PATH
  - OpenSSL is included with XAMPP, Git for Windows, or can be installed separately
- XAMPP (if you plan to use the certificates with XAMPP)

## How to Use

1. Download the `create_certs.bat` script to your computer
2. Open Command Prompt as Administrator
3. Navigate to the directory containing the script
4. Run the script:
   ```
   create_certs.bat
   ```
5. When prompted, enter your development domain (e.g., `example.com`)
6. The script will generate all necessary certificate files, including a **wildcard certificate** that works for all subdomains of your domain

## Generated Files

The script creates the following files:

| File | Description |
|------|-------------|
| `CAPrivate.key` | Private key for your Certificate Authority |
| `CAPrivate.pem` | Certificate Authority certificate (PEM format) |
| `CAPrivate.crt` | Certificate Authority certificate (CRT format) |
| `MyPrivate.key` | Private key for your server certificate |
| `MyRequest.csr` | Certificate Signing Request |
| `MyCert.crt` | Signed server certificate |
| `openssl.ss.cnf` | OpenSSL configuration for Subject Alternative Names |
| `installation.txt` | Instructions for installing the certificates |

## Sample Installation.txt File

When you run the script, it generates an `installation.txt` file that contains instructions specific to your domain. Here's what the file looks like (using "example.com" as the domain):

```
===============================================================
Installation Instructions for example.com
===============================================================

1. Install CA Certificate into Windows Trusted Root Store:
   - Open 'Manage user certificates'
   - Navigate to 'Trusted Root Certification Authorities'
   - Import CAPrivate.crt

2. For XAMPP:
   - Create these folders:
       * C:\xampp\apache\conf\certs\my-project
       * C:\xampp\htdocs\my-project

   - Copy these files to C:\xampp\apache\conf\certs\my-project:
       * MyCert.crt
       * MyPrivate.key
       * CAPrivate.crt

   - Configure virtual hosts in C:\xampp\apache\conf\extra\httpd-vhosts.conf:

       # HTTP VirtualHost (Port 80)
       <VirtualHost *:80>
           DocumentRoot "C:/xampp/htdocs/my-project"
           ServerName example.com
           ServerAlias www.example.com
           <Directory "C:/xampp/htdocs/my-project">
               Options Indexes FollowSymLinks MultiViews
               AllowOverride All
               Require all granted
           </Directory>
       </VirtualHost>

       # HTTPS VirtualHost (Port 443)
       <VirtualHost *:443>
           DocumentRoot "C:/xampp/htdocs/my-project"
           ServerName example.com
           ServerAlias www.example.com
           SSLEngine on
           SSLCertificateFile "conf/certs/my-project/MyCert.crt"
           SSLCertificateKeyFile "conf/certs/my-project/MyPrivate.key"
           SSLCertificateChainFile "conf/certs/my-project/CAPrivate.crt"
           <Directory "C:/xampp/htdocs/my-project">
               Options Indexes FollowSymLinks MultiViews
               AllowOverride All
               Require all granted
           </Directory>
       </VirtualHost>

   - Edit php.ini:
       openssl.cafile="C:\xampp\apache\bin\curl-ca-bundle.crt"

   - Append the following certificate to curl-ca-bundle.crt:

example.com
============================
-----BEGIN CERTIFICATE-----
MIIDvTCCAqWgAwIBAgIUJlq+zz4... (certificate content)
-----END CERTIFICATE-----
```

The file includes both the instructions and the actual certificate content that needs to be appended to the curl-ca-bundle.crt file.

## Installation in Windows

1. Install the CA Certificate into Windows Trusted Root Store:
   - Open "Manage user certificates" (certmgr.msc)
   - Navigate to "Trusted Root Certification Authorities"
   - Right-click on "Certificates" → "All Tasks" → "Import"
   - Browse to and select `CAPrivate.crt`
   - Follow the wizard to complete the import

## Configuring XAMPP

1. Create these folders:
   - `C:\xampp\apache\conf\certs\my-project`
   - `C:\xampp\htdocs\my-project`

2. Copy these files to `C:\xampp\apache\conf\certs\my-project`:
   - `MyCert.crt`
   - `MyPrivate.key`
   - `CAPrivate.crt`

3. Configure SSL in your virtual hosts configuration (see the "Virtual Host Configuration" section below).

4. Edit `php.ini` (located at `C:\xampp\php\php.ini`):
   ```
   openssl.cafile="C:\xampp\apache\bin\curl-ca-bundle.crt"
   ```

5. Append the CA certificate to `curl-ca-bundle.crt`:
   - Open `CAPrivate.crt` in a text editor
   - Copy the entire content
   - Open `C:\xampp\apache\bin\curl-ca-bundle.crt` in a text editor
   - Append the copied content at the end of the file
   - Save the file
   - **Note**: After appending the CA certificate to the curl-ca-bundle.crt file, you do not need to install this file into Windows. It is used directly by PHP from its location.

6. Restart Apache in the XAMPP Control Panel

## Virtual Host Configuration

To use your custom domain locally, you'll need to:

1. Edit your hosts file (`C:\Windows\System32\drivers\etc\hosts`):
   ```
   127.0.0.1 example.com 
   127.0.0.1 www.example.com
   ```

2. Configure virtual hosts in XAMPP by editing `C:\xampp\apache\conf\extra\httpd-vhosts.conf`:

   ### Standard VirtualHost for Port 80 (HTTP)
   ```
   <VirtualHost *:80>
       DocumentRoot "C:/xampp/htdocs/my-project"
       ServerName example.com
       ServerAlias www.example.com
       <Directory "C:/xampp/htdocs/my-project">
           Options Indexes FollowSymLinks MultiViews
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```

   ### VirtualHost for Port 443 (HTTPS)
   ```
   <VirtualHost *:443>
       DocumentRoot "C:/xampp/htdocs/my-project"
       ServerName example.com
       ServerAlias www.example.com
       SSLEngine on
       SSLCertificateFile "conf/certs/my-project/MyCert.crt"
       SSLCertificateKeyFile "conf/certs/my-project/MyPrivate.key"
       SSLCertificateChainFile "conf/certs/my-project/CAPrivate.crt"
       <Directory "C:/xampp/htdocs/my-project">
           Options Indexes FollowSymLinks MultiViews
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```


## Using Wildcard Certificates for Multiple Subdomains

The certificate generated by this script is automatically a wildcard certificate, which means it can be used for any subdomain of your main domain. Here's how to set up multiple subdomains using the same certificate:

1. **Add all subdomains to your hosts file** (`C:\Windows\System32\drivers\etc\hosts`):
   ```
   127.0.0.1 example.com www.example.com
   127.0.0.1 blog.example.com
   127.0.0.1 shop.example.com
   127.0.0.1 api.example.com
   ```

2. **Create separate virtual host entries** for each subdomain in `httpd-vhosts.conf`:
   ```
   # Blog subdomain
   <VirtualHost *:443>
       DocumentRoot "C:/xampp/htdocs/blog"
       ServerName blog.example.com
       SSLEngine on
       SSLCertificateFile "conf/certs/my-project/MyCert.crt"
       SSLCertificateKeyFile "conf/certs/my-project/MyPrivate.key"
       SSLCertificateChainFile "conf/certs/my-project/CAPrivate.crt"
       <Directory "C:/xampp/htdocs/blog">
           Options Indexes FollowSymLinks MultiViews
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>

   # Shop subdomain
   <VirtualHost *:443>
       DocumentRoot "C:/xampp/htdocs/shop"
       ServerName shop.example.com
       SSLEngine on
       SSLCertificateFile "conf/certs/my-project/MyCert.crt"
       SSLCertificateKeyFile "conf/certs/my-project/MyPrivate.key"
       SSLCertificateChainFile "conf/certs/my-project/CAPrivate.crt"
       <Directory "C:/xampp/htdocs/shop">
           Options Indexes FollowSymLinks MultiViews
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```

3. **Restart Apache** in the XAMPP Control Panel

All subdomains will use the same SSL certificate because the certificate includes the wildcard `*.example.com`, which covers all possible subdomains.

## Notes

- The default passphrase for the certificates is `1234` (you can change this in the script)
- The certificates are valid for 10 years (3650 days). **Important**: Remember to regenerate your certificates before they expire to avoid security warnings in browsers.
- **Wildcard Certificate**: The script automatically creates a wildcard certificate by including Subject Alternative Names (SAN) for both `www.example.com` and `*.example.com`
- The script will delete any existing certificate files in the directory before creating new ones

## Troubleshooting

- **Certificate not trusted**: Make sure you've properly imported the CA certificate into the Windows Trusted Root store
- **Cannot access site**: Ensure Apache is running and your hosts file is correctly configured
- **SSL errors in browser**: Try clearing your browser cache or restarting your browser
- **OpenSSL not found**: Make sure OpenSSL is installed and in your PATH environment variable
- **"Connection not private" warning**: Verify that the CA certificate is properly imported into the Trusted Root store
- **PHP curl errors**: Ensure you've correctly appended the CA certificate to curl-ca-bundle.crt and set the openssl.cafile path in php.ini
- **"ERR_SSL_VERSION_OR_CIPHER_MISMATCH"**: Check that your Apache SSL module is enabled and properly configured
- **Certificate works in Chrome but not Firefox**: Firefox uses its own certificate store; you may need to add an exception or import the CA certificate into Firefox
- **Multiple domains not working**: Ensure each domain/subdomain is properly added to your hosts file and has a corresponding VirtualHost entry

