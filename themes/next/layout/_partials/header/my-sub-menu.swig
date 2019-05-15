{% import '../../_macro/menu/menu-item.swig' as menu_item %}

<ul id="sub-menu" class="sub-menu menu">
{% for subname, subvalue in theme.topmenu %}
    {{ menu_item.render(subname, subvalue) }}
{% endfor %}
</ul>

