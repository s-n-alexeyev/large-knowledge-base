# Enable Two-Factor Authentication (2FA) in Windows with MultiOTP

В данной статье мы покажем, как реализовать двухфакторную аутентификацию для пользователей на Windows-домене с использованием бесплатного открытого пакета **multiOTP**. MultiOTC - это набор PHP классов и инструментов, позволяющий вам внедрить сервер на месте с сильной аутентификацией для HOTP и TOTP (Time-based One Time Password). Вы можете использовать его как в Windows, так и в любом другом операционном системе (через RADIUS) для включения двухфакторной аутентификации с одноразовым паролем.

После развертывания multiOTP Windows побуждает пользователя ввести одноразовый пароль, который он получает от своего мобильного устройства/смартфона (от Microsoft или Google Authenticator, или другой генератор OTP). Вы можете включить двухфакторную аутентификацию для пользователей при входе на Windows рабочие станции или доступ к RDS хостам на Windows Server через RDP.

MultiOTP предлагает офлайн-операцию (не требует доступа в интернет), поэтому вы можете использовать его для конфигурирования многофакторной аутентификации в отключенных средах. Большинство схожих приложений коммерческие или требуют прямого доступа к Интернету.

Contents:

- [Installing MultiOTP in Active Directory Domain](https://woshub.com/enable-2fa-in-windows-with-multiotp/#h2_1)
- [Configuring MultiOTP Two-Factor Authentication for Domain Users](https://woshub.com/enable-2fa-in-windows-with-multiotp/#h2_2)
- [How to install and Configure MultiOTP CredentialProvider on Windows?](https://woshub.com/enable-2fa-in-windows-with-multiotp/#h2_3)

## Installing MultiOTP in Active Directory Domain

In this section, we’ll show how to install multiOTP on Windows Server 2019 and configure user synchronization from Active Directory.

You can also deploy multiOTP using an OVA image for a VMware/Hyper-V virtual machine, or a Docker container.

Let’s start with the configuration of a multiOTP server that will get users from Active Directory, generate unique QR codes for users, and validate the second factor.

Create a security group in Active Directory and add users to it who will be required to pass the second-factor verification when logging into Windows. Create a group using PowerShell:

`New-ADGroup 2FAVPNUsers -path 'OU=Groups,OU=Munich,dc=woshub,DC=com' -GroupScope Global -PassThru –Verbose`

Add users to the group:

`Add-AdGroupMember -Identity 2FAVPNUsers -Members j.smith, k.berg, m.bakarlin`

[Create a new user in AD](https://woshub.com/new-aduser-create-active-directory-users-powershell/) multiOTP that will be used to access the AD catalog (with minimal privileges):

`$passwd = ConvertTo-SecureString -String "Paa32ssw0rd!" -AsPlainText -Force   New-ADUser -Name "multiotp_srv" -SamAccountName "multiotp_srv" -UserPrincipalName "[[email protected]](https://woshub.com/cdn-cgi/l/email-protection)" -Path "OU=ServiceAccounts,OU=Munich,DC=woshub,DC=com" –AccountPassword $passwd -Enabled $true`

Download the multiOTP archive – [https://download.multiotp.net/](https://download.multiotp.net/).

Open the multiotp_5.9.2.1.zip archive and extract the _windows_ directory from it to a folder on your local drive (`C:\MultiOTP`).

Open the command prompt and go to the directory containing multiotp.exe:

`CD C:\MultiOTP\windows`

Using the commands below, we will configure MultiOTP LDAP settings to get users from the Active Directory database.

`multiotp -config default-request-prefix-pin=0   multiotp -config default-request-ldap-pwd=0   multiotp -config ldap-server-type=1   multiotp -config ldap-cn-identifier="sAMAccountName"   multiotp -config ldap-group-cn-identifier="sAMAccountName"   multiotp -config ldap-group-attribute="memberOf"   multiotp -config ldap-ssl=0   multiotp -config ldap-port=389`

REM Domain controller IP address:

`multiotp -config ldap-domain-controllers=mun-dc1.woshub.com,ldap://192.168.15.15:389   multiotp -config ldap-base-dn="DC=woshub,DC=com"`

REM Account for multiOTP authentication in AD:

`multiotp -config ldap-bind-dn="CN=multiotp_srv,OU=ServiceAccounts,OU=Munich,DC=woshub,DC=com"   multiotp -config ldap-server-password="Paa32ssw0rd!"`

REM Group of users you want to enable OTP for:

`multiotp -config ldap-in-group="2FAVPNUsers"   multiotp -config ldap-network-timeout=10   multiotp -config ldap-time-limit=30   multiotp -config ldap-activated=1`

REM Key to access a MultiOTP server:

`multiotp -config server-secret=secret2OTP`

![configure MultiOTP server on Windows](https://woshub.com/wp-content/uploads/2022/09/configure-multiotp-server-on-windows.png.webp)

You can find a detailed description of all options in _HOW TO CONFIGURE MULTIOTP TO SYNCHRONIZED THE USERS FROM AN ACTIVE DIRECTORY_ section of [https://download.multiotp.net/readme_5.9.7.1.txt](https://download.multiotp.net/readme_5.9.7.1.txt) .

Earlier we created the **2FAVPNUsers** group and added 3 users to it. Synchronize AD users with multiOTP.

`multiotp -debug -display-log -ldap-users-sync`

LOG 2022-09-17 14:36:44 info LDAP Info: 3 users created, based on 3 LDAP entries (processed in 00:00:00)
LOG 2022-09-17 14:36:44 debug System Info: *File created: c:\MultiOTP\windows\.\users\j.smith.db

In this case, multiOTP has found 3 users and synchronized them.

![multiotp ldap-users-sync](https://woshub.com/wp-content/uploads/2022/09/multiotp-ldap-users-sync.png.webp)

To regularly synchronize new Active Directory accounts, create a Task Scheduler job using the command below:

`multiotp -debug -display-log -ldap-users-sync`

Run **webservice_install.cmd** as administrator. It will install multiOTP web management interface.

Sign-in MUltiOTP web interface (`http://127.0.0.1:8112/`) using default credentials (user: `admin`, password: `1234`). Then it is recommended to change it.

![MultiOtp install web administraion console](https://woshub.com/wp-content/uploads/2022/09/multiotp-install-web-administraion-console.png.webp)

## Configuring MultiOTP Two-Factor Authentication for Domain Users

In the **List of users** section, you will see a list of domain users synchronized earlier (AD/LDAP source).

![Synced Active Directory via LDAP users in multiOTP](https://woshub.com/wp-content/uploads/2022/09/synced-active-directory-via-ldap-users-in-multiotp.png.webp)

Select a user and click **Print**. You will see a user QR code to add to the authentication app.

![Get OTP QR code for Windows user](https://woshub.com/wp-content/uploads/2022/09/get-otp-qr-code-for-windows-user.png.webp)

Install the **Microsoft Authenticator** (or Google Authenticator) from Google Play or App Store on the user’s smartphone. Open it and scan the user’s QR code.

Then a new user account appears in the Authenticator app, which generates a new six-digit password (the second factor) every 30 seconds.

![One-teme password in Microsoft Authenticator app](https://woshub.com/wp-content/uploads/2022/09/one-teme-password-in-microsoft-authenticator-app.png.webp)

In the command prompt, you can make sure that multiOTP allows authenticating this user with OTP:

`multiotp.exe -display-log j.smith 130186`

where _130186_ is a one-time password you get from the app.

LOG 2022-09-17 15:13:11 notice (user j.smith) User OK: User j.smith successfully logged in with TOTP token
Filter-Id += "2FAVPNUsers"

![multiotp.exe -display-log](https://woshub.com/wp-content/uploads/2022/09/multiotp-exe-display-log.png.webp)

You can also make sure that OTP is working correctly through the web interface. Go to **Check a user** section, enter a user name and a one-time password.

![check users's one time password via web interface](https://woshub.com/wp-content/uploads/2022/09/check-userss-one-time-password-via-web-interface.png.webp)

## How to install and Configure MultiOTP CredentialProvider on Windows?

The next step is to install **multiOTP-CredentialProvider** on Windows computers you want to implement two-factor authentication using multiOTP. You can install CredentialProvider on any Windows 7/8/8.1/10/11 or Windows Server 2012(R2)/2016/2019/2022 host.

In this example, we will enable 2FA for RDP users to log in to an [RDSH server running Windows Server 2019](https://woshub.com/install-remote-desktop-services-rdsh-workgroup-without-domain/).

Download and install multiOTP CredentialProvider from GitHub [https://github.com/multiOTP/multiOTPCredentialProvider/releases](https://github.com/multiOTP/multiOTPCredentialProvider/releases). The last available version is 5.9.2.1.

Run the installation:

1. Specify the IP address of the server multiOTP is installed on.
    
    Remember to open a firewall port on the multiOTP server and client. You can open a [port in Windows Firewall on a server using PowerShell](https://woshub.com/manage-windows-firewall-powershell/):  
    `New-NetFirewallRule -DisplayName "AllowMultiOTP" -Direction Inbound -Protocol TCP –LocalPort 8112 -Action Allow`
    
2. Enter the secret key from the multiOTP configuration ( server-secret) in the field **Secret shared with multiOTP server**; ![Install multiOTP-CredentialProvider on Windows](https://woshub.com/wp-content/uploads/2022/09/install-multiotp-credentialprovider-on-windows.png.webp)
3. Select Windows logon type to apply OTP authentication. In our example, we will use 2FA for RDP logins only (**OTP authentication mandatory for remote desktop only**). ![enable: OTP authentication mandatory for remote desktop only](https://woshub.com/wp-content/uploads/2022/09/enable-otp-authentication-mandatory-for-remote-de.png.webp)

You can enable OTP authentication both for RDP and local logons.

MultiOTP CredentialProvider keeps its settings in the registry: `HKEY_CLASSES_ROOT\CLSID\{FCEFDFAB-B0A1-4C4D-8B2B-4FF4E0A3D978}`. If you want, you can change CredentialProvider settings here without reinstalling agent.

![MultiOTP CredentialProvider settings in registry](https://woshub.com/wp-content/uploads/2022/09/multiotp-credentialprovider-settings-in-registry.png.webp)

Restart the Windows Server RDS host and try to connect to it via RDP. After you enter your user credentials, a new one-time password window appears. Here you must enter a one-time password from your Authenticator app on your smartphone.

![Enter One-Time Password to Login RDS/RDP host running Windows](https://woshub.com/wp-content/uploads/2022/09/enter-one-time-password-to-login-rds-rdp-host-runn.png.webp)

If NLA for RDP is disabled on the RDS host, a user will just see three fields (username, password, and OTP).

![Login Windows using credentials and one-time password](https://woshub.com/wp-content/uploads/2022/09/login-windows-using-credentials-and-one-time-passw.png.webp)

You can enable logging on your multiOTP server, it is useful for debugging:

`multiotp -config debug=1   multiotp -config display-log=1`

Your script is running from C:\MultiOTP\windows\
2022-09-17 15:21:07 debug CredentialProviderRequest Info: *Value for IsCredentialProviderRequest: 1 0 MUN-SRVOTP1
2022-09-17 15:21:07 debug Server-Client Info: *CheckUserToken server request. 0 MUN-SRVOTP1
2022-09-17 15:21:07 notice j.smith User OK: User j.smith successfully logged in (using Credential Provider) with TOTP token 0 MUN-SRVOTP1
2022-09-17 15:21:07 debug Server-Client Info: *Cache level is set to 1 0 MUN-SRVOTP1
2022-09-17 15:21:07 debug Server-Client Info: *Server secret used for command CheckUserToken with error code result 0: secret2OTP 0 MUN-SRVOTP1

Remember to make sure that your AD domain synchronizes time with a reliable time source and client devices have the correct time. These are critical to the operation of OTP.

Anyway, before bulk multiOTP-based 2FA implementation in your network, we recommend testing all operation modes and emergencies (multiOTP server or DC unavailability, CredentialProvider errors, etc.) within a couple of weeks. If any serious issues with multiOTP logon occur, you can uninstall CredentialProvider in the Safe Mode.

So, the configuration of multiOTP two-factor authentication in Windows Server is over. There are also scenarios of using multiOTP with a RADIUS server to authenticate almost any type of client using OTP. You can use OTP for extra [protection of the RDP server against brute force attacks together with Windows Firewall rules](https://woshub.com/block-rdp-brute-force-powershell-firewall-rules/).