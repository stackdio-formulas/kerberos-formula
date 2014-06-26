{% set realm = grains.domain | upper %}
{% set kdc_list = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:krb5.kdc', 'grains.items', 'compound').values() %}

{% if kdc_list|length  == 0 %}
    {% set kdc = 'unknown.kdc.local.domain' %}
{% else %}
    {% set kdc = kdc_list[0]['fqdn'] %}
{% endif %}


{% set krb5 = {} %}
{% do krb5.update({
  'realm': grains.domain | upper,
  'realm_lower': grains.domain,
  'kdc': kdc | upper,
  'kdc_lower': kdc
}) %}
