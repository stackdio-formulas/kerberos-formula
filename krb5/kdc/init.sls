include:
 - krb5

krb5-server:
  pkg:
    - installed
    - require:
      - pkg: krb5-libs
      - pkg: krb5-workstation

krb_config:
  file:
    - recurse
    - name: /var/kerberos/krb5kdc
    - source: salt://krb5/kdc/conf
    - file_mode: 644
    - user: root
    - group: root
    - template: jinja
    - require:
      - pkg: krb5-server

krb_db:
  cmd:
    - run
    - name: '(echo; echo) | kdb5_util create -s'
    - unless: 'test -f /var/kerberos/krb5kdc/principal'
    - require:
      - file: krb_config

krb5kdc:
  service:
    - running
    - enable: true
