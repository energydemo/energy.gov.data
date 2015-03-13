jQuery(function() {

    var loadTemplate = function(basename) {
        var source    = jQuery('#' + basename + '-template').html();
        var template  = Handlebars.compile(source);
        var container = jQuery('#' + basename + 's-container');

        console.log(basename, 'loading...');
        jQuery.get('data/' + basename + 's.json', function(obj) {
            console.log('... loaded ', basename);

            jQuery.each(obj.data, function(ii, item) {
                var rendered = template(item);
                container.append(rendered);
            });
        });
    };

    loadTemplate('stakeholder');
    loadTemplate('topic');
});
