---
layout: layout
---

{{ content }}

{% capture lib_include %}{% include lib.md %}{% endcapture %}
{{ lib_include | markdownify }}
