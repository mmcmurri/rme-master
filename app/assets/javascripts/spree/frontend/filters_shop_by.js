/**
 * Created by Dmitry Kosenko
 */

//$( document ).ready(function() {
(function() {
    Spree.ready(function() {

        $("#lsidebar input[type='checkbox']").change(function() {
            var items = $("#lsidebar input:checkbox:checked");
            $.each(items, function(index, item) {
                var selector = $(item);
                console.log(index+") status:"+selector.is(":checked")+" val:"+selector.val()+" id:"+selector.attr("id"))
            });
        });
    });
}).call(this);
