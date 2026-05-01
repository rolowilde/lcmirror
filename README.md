# lcmirror

Free and Open Source Software repository mirror deployment solution. This
Ansible playbook installs sync scripts and configures a web server (Caddy),
crontab, vsftpd, and rsyncd.

Used in production at University of Latvia: [ftp.linux.edu.lv](https://ftp.linux.edu.lv/)

## Mirrored repositories

In order of implementation:

| Name       | Scripts                                                                 | Implemented                                      |
| ---------- | ----------------------------------------------------------------------- | ------------------------------------------------ |
| Arch Linux | mirrorsync                                                              | ✅                                                |
| Debian     | [archvsync](https://salsa.debian.org/mirror-team/archvsync), mirrorsync | ✅ (archive, cdimage)                             |
| Ubuntu     | [ubumirror](https://github.com/rolowilde/ubumirror)                     | ✅ (archive, cdimage, release, ports, cloudimage) |
| FreeBSD    | mirrorsync                                                              | ✅                                                |
| MX Linux   | mirrorsync                                                              | ✅ (packages, iso)                                |
| Linux Mint | mirrorsync                                                              | ✅ (packages, iso)                                |
| Fedora     | [quick-fedora-mirror](https://pagure.io/quick-fedora-mirror)            | ✅                                                |

## Usage

A fresh virtual machine or container is recommended to run this playbook on managed nodes; Debian 12-13 tested.

On the control node:

1. Install playbook requirements:

    ```shell
    ansible-galaxy install -r requirements.yml
    ```

2. Create an inventory file with hosts. Note that only hosts in the **mirrors** group are targetted by the playbook.

3. Configure hosts with vars provided in `inventory.example.yml`, as well as in roles' defaults.

4. Run playbook:

    ```shell
    ansible-playbook -i inventory site.yml
    ```

## Roles

### common

#### mirrorsync

Adopted from Arch Linux infrastructure maintainers, mirrorsync is a generic
role to be [included](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_role_module.html)
by other mirror roles that rely on a generic rsync script.
Original [script](https://gitlab.archlinux.org/archlinux/infrastructure/-/blob/1d5dbcd5819c4e9a340c1427fba0e0552c790fd2/roles/mirrorsync/templates/mirrorsync.j2)
has been extended to introduce logging with rotation and timestamp checking for
any repository.

The only required variable to be passed down to the role is `mirrorsync_name`,
based on which all the other options will be dynamically loaded with defaults.
Then, the actual mirror role has to specify the source url to pull from. See
all configurable vars and assumed defaults in mirrorsync's main tasks file.

### mirrors

Several repositories may be implemented in a single role, like debian (archive
and cdimage), toggleable with respective vars.

If a certain distribution's maintainers provide their recommended suite of sync
scripts, those are preferred to the generic `mirrorsync`.

### services

#### rsyncd

Installs and configures an Rsync server to let others sync from you.

> [!WARNING]
> The config file is overwritten every time this role runs. Mirror roles are
> expected to import this role with `tasks_from` set to `module.yml` and
> appropriate vars passed to the role to ensure the respective rsync module
> is appended to the config.

#### vsftpd

Install and configures an FTP server for browsing as anonymous user only.

## License

lcmirror is licensed under the MIT License.
