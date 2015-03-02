{%- from 'krb5/settings.sls' import krb5 with context -%}
#!/usr/bin/env python

from ConfigParser import ConfigParser
from StringIO import StringIO

with open('/etc/krb5.conf', 'rw') as f:

    # Seperate unparsable head from parsable body
    config = f.read().split('\n')
    header = "\n".join(config[:3])
    body = "\n".join(config[4:])
    cp = ConfigParser()
    cp.read(body)

    # Add realm
    REALMS = 'realms'
    realm = "\n".join(["{",
                       "    kdc = {{ krb5.kdc }}",
                       "    admin_server = {{ krb5.kdc }}",
                       "    default_domain = {{ krb5.kdc }}",
                       "  }"])
    cp.set(REALMS, '{{ krb5.realm }}', realm)

    # Add domain_realm
    DOMAIN_REALM = 'domain_realm'
    cp.set(DOMAIN_REALM, '{{ krb5.realm }}', '{{ krb5.realm }}')
    cp.set(DOMAIN_REALM, '.{{ krb5.realm }}', '{{ krb5.realm }}')

    # Add logging section
    LOGGING = 'logging'
    cp.add_section(LOGGING)
    cp.set(LOGGING, 'kdc', 'FILE:/var/log/krb5kdc.log')
    cp.set(LOGGING, 'admin_server', 'FILE:/var/log/kadmin.log')
    cp.set(LOGGING, 'default', 'FILE:/var/log/krb5lib.log')

    # Write ConfigParser to string
    strio = StringIO()
    cp.write(strio)
    strio.seek(0)
    new_body = strio.read()

    # Join new body to header and write to file
    f.seek(0)
    f.write("\n".join([header, new_body]))
