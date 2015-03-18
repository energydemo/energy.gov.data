jQuery("document").ready(function (event) {

    var source    = jQuery('#item-template').html();
    var template  = Handlebars.compile(source);
    var container = jQuery('#tagList');

    var ajax = jQuery.ajax('keyword_counts.json', {dataType: "json"});
    ajax.done(function(rawdata) {
        var arry = rawdata.data;
        var filtered = arry.reduce(
            function(buffer, item, ii) {
                if (item.frequency > 10) {
                    buffer.push(item);
                }
                return buffer;
            },
            []
        );

        // render list items
        jQuery.each(filtered, function(ii, item) {
            var rendered = template(item);
            container.append(rendered);
        });


        // fill tag canvas
        try {
            TagCanvas.Start('myCanvas', 'tagList');
        } catch(e) {
            // something went wrong, hide the canvas container
            document.getElementById('myCanvasContainer').style.display = 'none';
        }
    });

});
