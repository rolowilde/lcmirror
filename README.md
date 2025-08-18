# lcmirror

Free and Open Source Software repository mirror deployment solution. This Ansible playbook installs sync scripts and configures a web server (Caddy), crontab, vsftpd, and rsyncd.

Currently used at University of Latvia: [spulgs3.linuxcentrs.lv](https://spulgs3.linuxcentrs.lv/)

## Mirrored repositories

In order of implementation:

| Name | Scripts | Implemented |
| ---- | ------- | ----------- |
| Arch Linux | mirrorsync | ✅ |
| Debian | [archvsync](https://salsa.debian.org/mirror-team/archvsync), mirrorsync | ✅ (archive, cdimage) |
| Ubuntu | [ubumirror](https://github.com/rolowilde/ubumirror) | ✅ (archive, cdimage, release, ports, cloudimage) |
| FreeBSD | mirrorsync | ✅ |
| MX Linux | mirrorsync | ✅ (packages, iso) |
| Linux Mint | mirrorsync | ✅ (packages, iso) |
| Fedora | [quick-fedora-mirror](https://pagure.io/quick-fedora-mirror) | ⌛ |

## Usage

A fresh virtual machine or container is recommended to run this playbook on managed nodes; Debian 12-13 tested.

On the control node:

1. Install playbook requirements:

    ```shell
    ansible-galaxy install -r requirements.yml
    ```

2. Create an inventory file with hosts.
3. Configure hosts with vars provided in `example.yml`, as well as in roles' defaults.
   1. Specify additional users, cron jobs, and rsync modules (if any) in `common_users`, `common_cron_jobs`, `common_rsync` respectively. Refer to [users](https://github.com/robertdebock/ansible-role-users/tree/bb7b2b743eded04b9f5a7727682b75cea5249a50?tab=readme-ov-file#example-playbook), [cron](https://github.com/robertdebock/ansible-role-cron/tree/8dc5dceeae3bfdeb9a37c76d0cd709fb40ea7267?tab=readme-ov-file#example-playbook), [rsync-server](https://github.com/infOpen/ansible-role-rsync-server/tree/18a2ba608f7e6fd712cedc3a77c14a0b5653e556?tab=readme-ov-file#manage-rsync-configuration) for object schemas.
   2. Aforementioned lists are populated dynamically, depending on executed roles.
   3. Caddy, the HTTP(S) server, will not be configured (but installed by default) unless vars are set. A basic Caddyfile is provided in the example.
4. Run playbook:

    ```shell
    ansible-playbook -i inventory site.yml
    ```

## Roles

Several repositories may be implemented in a single role, like debian (archive and cdimage), toggleable with respective vars.

### mirrorsync

Adopted from Arch Linux infrastructure maintainers, mirrorsync is a generic role to be [included](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_role_module.html) by other mirror roles that rely on a generic rsync script. Original [script](https://gitlab.archlinux.org/archlinux/infrastructure/-/blob/1d5dbcd5819c4e9a340c1427fba0e0552c790fd2/roles/mirrorsync/templates/mirrorsync.j2) has been extended to introduce logging with rotation and timestamp checking for any repository.

The only required variable to be passed down to the role is `mirrorsync_name`, based on which all the other options will be dynamically loaded with defaults. Then, the actual mirror role has to specify the source url to pull from. For example, given the following project structure:

```yaml
.
└── roles/
    ├── common/
    ├── mirrorsync/
    └── example/
        ├── defaults/
        │   └── main.yml
        └── tasks/
            └── main.yml

---
# ./roles/example/defaults/main.yml
example_source_url: rsync://example.com/root/

---
# ./roles/example/tasks/main.yml
- name: Include mirrorsync role
  ansible.builtin.include_role:
    name: mirrorsync
  vars:
    mirrorsync_name: example # prefix for vars to lookup
```

See all configurable vars and assumed defaults in mirrorsync's main tasks file.

## License

lcmirror is licensed under the MIT License. Please consult the attached LICENSE file for further details.
