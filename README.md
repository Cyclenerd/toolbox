# 🔧 Toolbox

My collected scripts for which no extra repository is worth it.
Mostly in Perl.
Maybe they'll help you.
Use at your own risk ☺️.
They were often quickly hacked and poorly tested.

🚨🚨🚨 No warranty or support! 🚨🚨🚨

## MySQL

* `check_replication_status.sh` - Check MySQL 8.0 replication status and send email on error
* `check_replication_status_hc.sh` - Check MySQL 8.0 replication status and ping [healthchecks.io](https://healthchecks.io/)

Used in Ansible Playbook:
```yml
# Check MySQL 8.0 replication and ping to healthchecks.io
- name: Script - Check status and ping healthchecks.io
  ansible.builtin.get_url:
    url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/check_replication_status_hc.sh
    dest: /root/check_replication_status_hc.sh
    mode: '0755'
    owner: root
    group: root
- name: Script - Change healthchecks.io UUID
  ansible.builtin.lineinfile:
    path: /root/check_replication_status_hc.sh
    regexp: '^MY_HC_ID'
    line: "MY_HC_ID='{{ healthchecks_uuid }}'"
```

## License

GNU Public License version 3.
Please feel free to fork and modify this on GitHub (https://github.com/Cyclenerd/toolbox).
