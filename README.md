# lcmirror

Free and Open Source Software repository mirror deployment solution. This Ansible playbook installs sync scripts and configures a web server (Caddy), crontab, vsftpd, and rsyncd.

Currently used at University of Latvia: [spulgs3.linuxcentrs.lv](https://spulgs3.linuxcentrs.lv/)

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
| openSUSE   | mirrorsync                                                              | ⏳                                                |
| Gentoo     | mirrorsync                                                              | ⏳                                                |

## Usage

### OpenTofu (Terraform) with Ansible

Example root module `terraform.tf` is provided in the repository to provision an LXC container in Proxmox Virtual Environment. It assumes Debian 13 standard container template is available, ZFS local storage, `/tank/mirror` dataset as the container mountpoint, and that hostnames resolve under DNS search domain of the PVE node. At the time, *only* OpenTofu is supported due to its native encrypted state functionality.

Root password and SSH keys are generated automatically and available through `tofu output`. Bind mounts require `root@pam` authentication as per `bpg/terraform` provider [documentation](https://github.com/bpg/terraform-provider-proxmox/blob/a514610afb6f0b35f6bcfb9366eaf565c35b76fd/docs/resources/virtual_environment_container.md#example-usage). Ansible hosts are created dynamically via the provider and then pulled from OpenTofu state by `cloud.terraform.terraform_provider` inventory plugin.

Specify playbook vars in `terraform.tf` or as described in the following section.

If an SSH agent is set up on the local machine, the generated private key can be piped to `ssh-add`. Provision with a one-liner:

```shell
ansible-galaxy install -r requirements.yml # if not installed
tofu apply && tofu output -raw lcmirror_ssh_private_key | ssh-add - && ansible-playbook site.yml
```

### Ansible

A fresh virtual machine or container is recommended to run this playbook on managed nodes; Debian 12-13 tested.

On the control node:

1. Install playbook requirements:

    ```shell
    ansible-galaxy install -r requirements.yml
    ```

2. Create an inventory file with hosts.
   1. This is not necessary when provisioning by the OpenTofu example.
   2. Otherwise, specify hosts in the inventory as usual.
   3. Only hosts in the **mirrors** group are targetted by the playbook.

3. Configure hosts with vars provided in `example.yml`, as well as in roles' defaults.
   1. Override defaults in `group_vars/mirrors.yml` for all hosts and `host_vars/*.yml` per host.
   2. Specify additional users, cron jobs, and rsync modules (if any) in `common_users`, `common_cron_jobs`, `common_rsync` respectively. Refer to [users](https://github.com/robertdebock/ansible-role-users/tree/bb7b2b743eded04b9f5a7727682b75cea5249a50?tab=readme-ov-file#example-playbook), [cron](https://github.com/robertdebock/ansible-role-cron/tree/8dc5dceeae3bfdeb9a37c76d0cd709fb40ea7267?tab=readme-ov-file#example-playbook), [rsync-server](https://github.com/infOpen/ansible-role-rsync-server/tree/18a2ba608f7e6fd712cedc3a77c14a0b5653e556?tab=readme-ov-file#manage-rsync-configuration) for object schemas.
   3. Aforementioned lists are populated dynamically, depending on executed roles.
   4. Caddy, the HTTP(S) server, will not be configured (but installed by default) unless vars are set. A basic Caddyfile is provided in the example.
   5. Set `rsyncd` and/or `vsftpd` to `false` if those services are not desired.
   6. Set `update_reboot` to `false` if reboot handler is not desired.

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
