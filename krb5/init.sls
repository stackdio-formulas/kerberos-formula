krb5-libs:
  pkg.installed

krb5-workstation:
  pkg.installed

/etc/krb5.conf:
  file.managed:
    - source: salt://krb5/etc/krb5.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - pkg: krb5-libs
      - pkg: krb5-workstation
