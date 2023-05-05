# Login to the Linux Server #
Version 0.1 (not tested - use at your own risk)

There are serveral ways to login to the Field Museum Linux server and to transfer files between your computer and the server.

## Using Windows ##
If you're using Windows, you can use [Kitty](http://www.9bis.net/kitty/?page=Welcome&zone=en) to access to the server via command line.

1. Download the uncompressed version of the program [here](http://www.9bis.net/kitty/?page=Download)
2. Start the downloaded .exe file by double clicking
3. Enter the ip address of the server in **Host Name (or IP address)**
4. Click **Open**  

For file transfer you can use WinSCP.

1. Download and install [WinSCP](https://winscp.net/eng/download.php)
2. Enter ip address of the server in **Host name**
3. Enter your username in **User name**
4. Click **Login**  
You can transfer files by drag & drop

## Using MacOS ##
If you're using a Apple computer, you can use the **Terminal** to access the Linux servers by command line.

1. Open Terminal
2. Enter:  
~~~
ssh your_user_name@ip_address_of_the_server  
~~~
(Type your username and password when asked. For your password protection, you won't see any symbols when typing your password.)

For file transfer from iOS, use e.g. the program **cyberduck**:

1. Download and install the program [here](https://cyberduck.io/)
2. Click on **Open Connection**
3. Switch to **SFTP** protocol, enter the ip address of the server you ant to connect to, and your user name
4. Click **Connect**

Or you can use a program called **FileZilla**:

1. Download the FileZilla via [link](https://dl1.cdn.filezilla-project.org/client/FileZilla_3.63.2.1_macosx-x86.app.tar.bz2?h=kiLDRwI9S2qSKA1Igtwo2w&x=1680277795)
2. Open the program without installation
3. Enter the serber IP, type in your username and password
4. Use **22** for the port and click Quickconnect

## Learn more about the use of the Linux command line ##
See the CBFM class website [here](http://cbfm.github.io/website/)

