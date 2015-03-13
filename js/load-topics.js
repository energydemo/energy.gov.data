jQuery(function() {
    var source    = jQuery('#baseball-card-template').html();
    var template  = Handlebars.compile(source);

    var container = jQuery('#baseball-card-container');
    var ajaxRequest = jQuery.ajax('data/topics.json');

    ajaxRequest.done(function(str) {
        var obj    = JSON.parse(str);
        var topics = obj.topics;

        jQuery.each(topics, function(ii, topic) {
            var rendered = template(topic);
            container.append(rendered);
        });
    });
});
