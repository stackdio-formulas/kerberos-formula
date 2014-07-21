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
    - watch:
      - file: krb_config
    - require:
      - cmd: krb_db
      - file: krb_config

kadmin:
  service:
    - running
    - enable: true
    - require:
      - service: krb5kdc

##
# The following will generate a new keytab for the kadmin/admin principal
# and push the resulting keytab back to the master for safe keeping. Any
# machines requiring admin access (e.g., for automating the creation of
# additional principals on the respective machines) can then retrieve
# the admin keytab.
##
gen_admin_keytab:
  cmd:
    - run
    - name: 'kadmin.local -q "xst -norandkey -k /root/admin.keytab kadmin/admin@DEV.SYNTHESYSCLOUD.COM"'
    - unless: 'test -f /root/admin.keytab'
    - require:
      - service: krb5kdc

push_admin_keytab:
  module:
    - run
    - name: cp.push
    - path: /root/admin.keytab
    - require:
      - cmd: gen_admin_keytab
