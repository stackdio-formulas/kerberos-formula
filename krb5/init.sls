krb5-libs:
  pkg.installed

krb5-workstation:
  pkg.installed

/etc/krb5.conf.d:
  file:
    - directory
    - user: root
    - makedirs: true
    - require:
      - pkg: krb5-libs
      - pkg: krb5-workstation

move_old_conf:
  cmd:
    - run
    - name: 'mv /etc/krb5.conf /etc/krb5.conf.d/old_krb5_conf'
    - onlyif: 'test -f /etc/krb5.conf && ! test -f /etc/krb5.conf.d/old_krb5_conf'
    - require:
      - file: /etc/krb5.conf.d

/etc/krb5.conf.d/stackdio_krb5_conf:
  file.managed:
    - source: salt://krb5/etc/krb5.conf.d/stackdio_krb5.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - cmd: move_old_conf

/etc/krb5.conf:
  file.managed:
    - source: salt://krb5/etc/krb5.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/krb5.conf.d/stackdio_krb5_conf
