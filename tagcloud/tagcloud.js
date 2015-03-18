jQuery("document").ready(function (event) {

    var source    = jQuery('#item-template').html();
    var template  = Handlebars.compile(source);
    var container = jQuery('#tagList');

    var ajax = jQuery.ajax('keyword_counts.json', {dataType: "json"});

    // configuration
    var gradient = {
        0:    '#f00', // red
        0.33: '#ff0', // yellow
        0.66: '#0f0', // green
        1:    '#00f'  // blue
    };
    TagCanvas.weight = true;
    TagCanvas.weightGradient = gradient;
    TagCanvas.weightFrom = 'data-weight';
    TagCanvas.weightMode = 'both';

    // start the whole thing off with Ajax call
    ajax.done(function(rawdata) {
        var arry = rawdata.data;
        var filtered = arry.reduce(
            function(buffer, item, ii) {
                if (item.frequency > 20) {
                    item.frequency = Math.log(item.frequency) * 10;
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
            TagCanvas.Start('myCanvas',
                            'tagList',
                            {
                                // textColour: 'black',
                                maxSpeed: 0.05
                            }
                           );
        } catch(e) {
            // something went wrong, hide the canvas container
            // document.getElementById('myCanvasContainer').style.display = 'none';
            console.log('ERROR', e);
        }
    });

});
