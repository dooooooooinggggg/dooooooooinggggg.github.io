---
layout: default
---

<div class="home">
  {%- if page.title -%}
  <h1 class="page-heading">{{ page.title }}</h1>
  {%- endif -%} {{ content }}

  <p>Last updated: {{ page.last_modified_at }}</p>
  <!-- <p>Last updated Repository: {{ site.time }}</p> -->

</div>
