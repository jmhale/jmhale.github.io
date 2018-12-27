---
# You don't need to edit this file, it's empty on purpose.
# Edit theme's home layout instead if you wanna make some changes
# See: https://jekyllrb.com/docs/themes/#overriding-theme-defaults
layout: default
---
<h1>{{ page.title }}</h1>
<!-- <ul class="posts">

  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> » <a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></li>
  {% endfor %}
</ul> -->

{% for post in site.posts limit:10 %}
   <div class="post-preview">
   <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
   <span class="post-date">{{ post.date | date: "%Y-%m-%d" }}
   {% if site.read-time %}: {% include read-time.html content=post.content %}{% endif %}</span>
   {{ post.content | split:'<!--break-->' | first }}
   {% if post.content contains '<!--break-->' %}
      <a href="{{ post.url }}">read more</a>
   {% endif %}
   </div>
   <hr>
{% endfor %}
