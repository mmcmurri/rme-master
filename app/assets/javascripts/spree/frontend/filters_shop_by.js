/**
 * Created by Dmitry Kosenko
 */

//$( document ).ready(function() {
(function() {
    Spree.ready(function() {
        var url = "/shop/shops_ajax";

        function add_params_to_url(param_name, params) {
//            if (url_params.length < 1) url_params = "?";
            var url_params = param_name+"=";
            $.each(params, function(index, item) {
                var selector = $(item);
                url_params += selector.val() + ",";
            });
            url_params += "&";
            return url_params;
        }

        $("#lsidebar input[type='checkbox']").change(function() {
            var url_params = "?";

            var materials = $("#lsidebar #shop_by_material :input:checkbox:checked");
            var colors = $("#lsidebar #shop_by_color :input:checkbox:checked");
            var categories = $("#lsidebar #shop_by_categories :input:checkbox:checked");
            var brands = $("#lsidebar #shop_by_brand :input:checkbox:checked");
            var prices = $("#lsidebar #shop_by_price :input:checkbox:checked");

            //var items = $("#lsidebar input:checkbox:checked");

            url_params += add_params_to_url("materials", materials);
            url_params += add_params_to_url("colors", colors);
            url_params += add_params_to_url("categories", categories);
            url_params += add_params_to_url("brands", brands);
            url_params += add_params_to_url("prices", prices);

            var url_current = url+url_params;
            console.log(url_current);


//            var items = $("#lsidebar input:checkbox:checked");
//            $.each(items, function(index, item) {
//                var selector = $(item);
//                console.log(index+") status:"+selector.is(":checked")+" val:"+selector.val()+" id:"+selector.attr("id"))
//            });
        });
    });
}).call(this);
