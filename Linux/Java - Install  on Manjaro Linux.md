Installing Java and switching between different versions of java has never been this easy.

Download .tar.gz file for the JDK version that you require.

Extract the downloaded .tar.gz file using below command

```bash
tar -xvf jdk-11.0.10_linux-x64_bin.tar.gz
```

Move the extracted folder to /usr/lib/jvm. This path is the key as the arch linux, by default, looks for the available jvm here.

```bash
sudo mv jdk-11.0.10_linux-x64_bin /usr/lib/jvm
```

Now, to check if the jdk is recognized by arch linux, lets run below command

```bash
archlinux-java status
```

The JDKs available in the system under /usr/lib/jvm will be listed as shown above. Now its time to select the version of java that we need, which is indicated by the flag (default).

The below command will set jdk-11.0.10 as default.

```bash
sudo archlinux-java set jdk-11.0.10
```

Now lets verify the java version to make sure the changes are effective.

```bash
java -version
```