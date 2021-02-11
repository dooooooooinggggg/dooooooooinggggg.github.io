---
layout: layout
---

{{ content }}

{% capture notes_include %}{% include notes.md %}{% endcapture %}
{{ notes_include | markdownify }}
