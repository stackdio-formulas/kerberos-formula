#!/usr/bin/env python
#{%- from 'krb5/settings.sls' import krb5 with context -%}

import re
from ConfigParser import ConfigParser
from StringIO import StringIO

READ_FILE_PATH = '/etc/krb5.conf'
WRITE_FILE_PATH = '/etc/krb5.conf'


def main():
    file_content = read_conf_file()
    header, body = from_apache_conf(file_content)
    new_body = edit_config_body(body)
    new_file_content = to_apache_conf(header, new_body)
    write_conf_file(new_file_content)


def read_conf_file():
    with open(READ_FILE_PATH, 'r') as f:
        return f.read()


def from_apache_conf(file_content):
    # Seperate unparsable head from parsable body
    lines = file_content.split("\n")
    header = "\n".join(lines[:3])

    body_lines = lines[4:]

    # Remove indents below sections
    body = "\n".join([line.strip() for line in body_lines])

    # Replace \n between {} with |
    body = replace_between_braces(body, "\n", "|")

    return header, body


def edit_config_body(body):
    cp = str_to_config_parser(body)

    # Add realm
    REALMS = 'realms'
    realm = "|".join(["{",
                      "  kdc = {{ krb5.kdc }}",
                      "  admin_server = {{ krb5.kdc }}",
                      "  default_domain = {{ krb5.kdc }}",
                      "}"])
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

    return config_parser_to_str(cp)


def str_to_config_parser(s):
    cp = ConfigParser()
    io = StringIO()
    io.write(s)
    io.seek(0)
    cp.readfp(io)
    return cp


def config_parser_to_str(cp):
    io = StringIO()
    cp.write(io)
    io.seek(0)
    s = io.read()
    return s


def to_apache_conf(header, body):
    # Replace | between {} with \n
    body = replace_between_braces(body, "|", "\n")

    # Add indents below sections
    body = "\n".join(["  %s" % line if not line.startswith("[") else line
                      for line in body.split("\n")])

    # Rejoin header and return
    return "\n\n".join([header, body])


def replace_between_braces(text, frm, to):
    regex = re.compile('(\{(?:\s*\S+\s*)*?\})')
    text_regex_parts = [
        s.replace(frm, to) if s.startswith('{') else s
        for s in regex.split(text)
    ]
    return "".join(text_regex_parts)


def write_conf_file(file_content):
    with open(WRITE_FILE_PATH, 'w') as f:
        f.write(file_content)


if __name__ == '__main__':
    main()
