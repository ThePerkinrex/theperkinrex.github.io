---
layout: page
favicon: JiroSmall.png
title: Jiro Downloads Page
permalink: /jiro/downloads/
show: false
---
{% assign res_files = site.static_files | where: "res", true %}
{% assign installerarr = res_files | where: "name", "install-jiro.sh" %}
{% assign installer = installerarr[0] %}
{% assign uninstallerarr = res_files | where: "name", "uninstall-jiro.sh" %}
{% assign uninstaller = installerarr[0] %}
 * ### Installer:
    * #### <a href="{{installer.path | escape}}" id="installer" target="_blank">Download for UNIX systems (OSX and Linux)</a>
    * #### Windows download is not available
    * #### [HOWTO](#how-do-i-install-jiro)
 * ### Uninstaller:
    * #### <a href="{{uninstaller.path | escape}}" id="uninstaller" target="_blank">Download for UNIX systems (OSX and Linux)</a>
    * #### Windows download is not available
    * #### [HOWTO](#how-do-i-uninstall-jiro)

## How do I install Jiro

### For UNIX systems: OSX and Linux
First download the [installer](#installer) from this page.
Then open up a command line and go to the directory where the installer is:

In our case the installer in at `~/Downloads/`, so

`cd ~/Downloads`

Then give the installer rights to execute

`chmod +x install-jiro.sh`

And finally execute it

`./install-jiro.sh`

It might ask for an admin password as it is trying to write to `/usr/local/`
### For Windows
There's currently not an installer available for Windows

## How do I uninstall Jiro


### For UNIX systems: OSX and Linux
First download the [uninstaller](#uninstaller) from this page.
Then open up a command line and go to the directory where the uninstaller is:

In our case the uninstaller in at `~/Downloads/`, so

`cd ~/Downloads`

Then give the uninstaller rights to execute

`chmod +x uninstall-jiro.sh`

And finally execute it

`./uninstall-jiro.sh`

It might ask for an admin password as it is trying to remove to `/usr/local/jiro`
### For Windows
There's currently not an uninstaller available for Windows
