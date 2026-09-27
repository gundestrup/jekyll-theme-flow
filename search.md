---
layout: default
title: Search
permalink: /search/
nav_exclude: true
---

{% if site.client_search.enabled %}
{% search_form %}
{% else %}
Search is not enabled. Set `client_search.enabled: true` in `_config.yml`.
{% endif %}
