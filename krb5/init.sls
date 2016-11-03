krb5-libs:
  pkg.installed: []

krb5-workstation:
  pkg.installed: []

krb5_conf_file:
  file.managed:
    - source: salt://krb5/etc/krb5.conf
    - name: {{ pillar.krb5.conf_file }}
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - makedirs: true

/etc/profile.d/krb5.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents:
      - export KRB5_CONFIG={{ pillar.krb5.conf_file }}
