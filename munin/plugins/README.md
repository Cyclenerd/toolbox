# Munin Plugins

## MySQL

Ubuntu:
```
apt install munin-node munin-plugins-extra
```

Dir: `/usr/share/munin/plugins/`

* [x] mysql_bytes
* [ ] [mysql_connections](mysql_connections)
* [ ] [mysql_keybuffer](mysql_keybuffer)
* [ ] [mysql_keys](mysql_keys)
* [ ] [mysql_qcache_hits](mysql_qcache_hits)
* [ ] [mysql_qcache_mem](mysql_qcache_mem)
* [x] mysql_queries
* [ ] [mysql_size_](mysql_size_)
* [x] mysql_slowqueries
* [x] mysql_threads

> * [x] Included in the Ubuntu package
> * [ ] Must be installed manually

Used in Ansible Playbook:

```yml
# MySQL
- name: Munin node - Check MySQL server
  ansible.builtin.stat:
    path: /usr/sbin/mysqld
  register: mysqld
- name: Munin node - Download more MySQL plugins
  ansible.builtin.get_url:
    url: "{{ item.url }}"
    dest: "/usr/local/share/munin/plugins/{{ item.file }}"
    mode: '0755'
    owner: root
    group: root
  loop:
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_connections, file: mysql_connections }
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_keybuffer,   file: mysql_keybuffer }
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_keys,        file: mysql_keys }
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_qcache_hits, file: mysql_qcache_hits }
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_qcache_mem,  file: mysql_qcache_mem }
      - { url: https://raw.githubusercontent.com/Cyclenerd/toolbox/master/munin/plugins/mysql_size_,       file: mysql_size_ }
  when:
    mysqld.stat.exists
```