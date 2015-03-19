jQuery(function() {

    var loadTemplate = function(basename) {
        var source    = jQuery('#' + basename + '-template').html();
        var template  = Handlebars.compile(source);
        var container = jQuery('#' + basename + 's-container');
        var ajax;

        console.log(basename, 'loading...');
        ajax = jQuery.ajax('data/' + basename + 's.json', {dataType: "json"});
        ajax.done(function(obj) {
            console.log('... loaded ', basename);

            jQuery.each(obj.data, function(ii, item) {
                var rendered = template(item);
                container.append(rendered);
            });
        });
    };

    loadTemplate('stakeholder');
    loadTemplate('topic');
    loadTemplate('news-item');
});
