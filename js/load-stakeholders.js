jQuery(function() {
    var source    = jQuery('#stakeholder-template').html();
    var template  = Handlebars.compile(source);

    var container = jQuery('#stakeholders-container');
    var ajaxRequest = jQuery.ajax('data/stakeholders.json');

    ajaxRequest.done(function(str) {
        var obj          = JSON.parse(str);
        var stakeholders = obj.stakeholders;

        jQuery.each(stakeholders, function(ii, stakeholder) {
            var rendered = template(stakeholder);
            container.append(rendered);
        });
    });
});
