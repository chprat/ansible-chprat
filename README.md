This README file contains information on the contents of the ansible-chprat repository.

Please see the corresponding sections below for details.

General
=======

This repository contains a set of [Ansible](https://www.ansible.com/) configuration
files that can be used to set up devices. It is mainly targeted for
[Raspberry Pis](https://www.raspberrypi.com/) but can also be used for other devices.

I also use it to get started and play around with Ansible.

Setup Ansible
=============

The easiest way to install it on your Linux distribution is the package
management system. See the
[Ansible help](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
for more information.

Additional collections
----------------------

This repository uses collections that might not be installed by default.
These are the collections:

- ansible.posix
- community.general

You can install them with the following commands:

```
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

Repository preparation
======================

To not spread personal information and allow customization some files need to be adapted
before being usable.

Store become password
---------------------

Become is the equivalent of running a task with ``sudo`` on the target. Therefore you usually
need to type in a password, which is not very convenient during automatic running. You can
store your ``sudo`` password in an encrypted Ansible vault and even automatically feed the
vault password to the command line.

1. Create a new vault ``vars/become.yml`` and set it's access password
2. An editor will be opened where you can add your secrets
3. Add your ``sudo`` password as plain text for the ansible_become_password variable
4. Save the file and close the editor
5. Store your Ansible vault password as plain text in the file ``vault.txt``

The commands for creating the vault and verifying that everything is set up correctly
look like this:

```
$ ansible-vault create vars/become.yml
New Vault password: my-secret-password
Confirm New Vault password: my-secret-password

$ ansible-vault view vars/become.yml
Vault password: my-secret-password
ansible_become_password: my-super-secret-password

$ cat vault.txt
my-secret-password
```

The ``play.sh`` script and the playbooks will automatically use the Ansible vault and the
vault password file so that you won't have to type in any ``sudo`` password during the run.

User variable modifications
---------------------------

Some user specific settings are stored in the file ``vars/user.yml`` that you'll have to
create before you can run the playbooks successfully. The template for the file looks
like this:

```
git_name: chprat
git_mail: cprater@gmx.net
user_password: 
user_pubkey: "{{ lookup('env', 'HOME') }}/.ssh/authorized_keys"
user_name: 
user_group: users
```

The variables are used for the following:

* git_name: user name used for git config
* git_mail: user email address used for git config
* user_password: encrypted password to log in as user
* user_pubkey: ssh public key file to log in via SSH
* user_name: default user name
* user_group: primary user group

Make sure that all variables are adjusted to your needs. To generate an encrypted password
use the command ``mkpasswd --method=sha-512`` and enter the password when asked for. When
adding the result string to the ``user.yml``, no quotes or escape characters are needed.

Playbook modifications
----------------------

Make sure that the file ``rpi48.yml`` matches your needs regarding tasks that should be run
and that the host and user names are configured correctly.

Setting up a Raspberry Pi from scratch
======================================

These steps are necessary for semi-automatic set up of a Raspberry Pi.

1. Flash an SD-card with an image you like
2. Reinsert/-mount the SD-card to access the boot partition
3. Create an empty file named ``ssh`` on the boot partition for enabling SSH on boot
4. Copy a prepared ``wpa_supplicant.conf`` on the boot partition for enabling WiFi on boot
5. Copy a prepared SSH public key on the boot partition
6. Boot the Raspberry Pi from the SD-card
7. Set up the hostname using e.g. ``raspi-config``
8. Create a ``.ssh`` folder in the home directory of the current user
9. Move the SSH public key file from the boot partition to the ``.ssh`` folder
10. Rename the SSH public key file to ``authorized_keys``
11. Make sure that the owner and file permissions of the ``authorized_keys`` file are correct
12. Execute ``./play.sh rpi48.yml`` to run the playbook
