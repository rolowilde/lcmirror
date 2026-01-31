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

TODO

## Roles

Several repositories may be implemented in a single role, like debian (archive
and cdimage), toggleable with respective vars.

### mirrorsync

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

## License

lcmirror is licensed under the MIT License.
