krb5-libs:
  pkg.installed

krb5-workstation:
  pkg.installed

move_old_conf:
  cmd:
    - run
    - name: 'mv /etc/krb5.conf /etc/krb5.conf.backup'
    - onlyif: 'test -f /etc/krb5.conf'

krb5_conf_file:
  file.managed:
    - source: salt://krb5/etc/krb5.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - makedirs: true
    - require:
      - cmd: move_old_conf
