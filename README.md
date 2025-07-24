# lcmirror

Production-ready software distribution mirror deployment solution. This Ansible playbook installs sync scripts and cronjobs, and configures HTTP/S, FTP, rsyncd services.

## Repos

| Name | Scripts | Implemented |
| ---- | ------- | ----------- |
| Arch Linux | mirrorsync* | ✅ |
| Debian | [archvsync](https://salsa.debian.org/mirror-team/archvsync) | ✅ (archive, cdimage) |
| Ubuntu | [ubumirror](https://github.com/rolowilde/ubumirror) | ✅ (archive, cdimage, release, ports, cloudimage) |
| FreeBSD | mirrorsync | ✅ |
| MX Linux | mirrorsync | ✅ (packages, iso) |
| Linux Mint | mirrorsync | ✅ (packages, iso) |
| Fedora | [quick-fedora-mirror](https://pagure.io/quick-fedora-mirror) | ⌛ |

**[mirrorsync.j2](https://gitlab.archlinux.org/archlinux/infrastructure/-/blob/1d5dbcd5819c4e9a340c1427fba0e0552c790fd2/roles/mirrorsync/templates/mirrorsync.j2), courtesy of Arch Infra maintainers, modified to be as generic as possible*

## Roles

General roles and 'mirrors' are found in seperate directories. Unless a repository has its own set of scripts provided by the maintainers, mirror roles import the `mirrorsync` role which performs variable lookups based on the provided repo name and sets up the mirror in a generic way. A 'mirror' must contain as many submodules as possible (`debian`, but not `debian-archive` and `debian-cd` separately).

For example, Debian provides `ftpsync` which is installed and configured in `mirrors/debian/tasks/archive.yml`. `ftpsync` only syncs the archive, but not CD images. For those, we set up a generic mirror by importing the aforementioned role in `mirrors/debian/tasks/cd.yml`. On the other hand, Ubuntu's `ubumirror` has a bunch of scripts including archive, CD images, ports, etc. that suffice.

## License

lcmirror is licensed under the MIT License. Please consult the attached LICENSE file for further details.
