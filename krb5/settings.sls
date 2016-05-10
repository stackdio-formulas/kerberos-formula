{% set domain_lower = grains.domain %}
{% set domain = domain_lower | upper %}
{% set realm_lower = grains.namespace ~ '.' ~ grains.domain %}
{% set realm = realm_lower | upper %}
{% set kdc_list = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:krb5.kdc', 'grains.items', 'compound').values() %}

{% if kdc_list|length  == 0 %}
    {% set kdc = 'unknown.kdc.local.domain' %}
{% else %}
    {% set kdc = kdc_list[0]['fqdn'] %}
{% endif %}


{% set krb5 = {} %}
{% do krb5.update({
  'domain_lower': domain_lower,
  'domain': domain,
  'realm': realm,
  'realm_lower': realm_lower,
  'kdc': kdc | upper,
  'kdc_lower': kdc
}) %}
