/**
 * Created by Dmitry Kosenko
 */

//$( document ).ready(function() {
(function() {
    Spree.ready(function() {

        init();

        var url = "/shop/shops_ajax.js";

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


        function make_url_for_ajax_call() {
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

            //$("a#filter").attr("href", url).click(); //make ajax call automatically

            $.ajax({
                method: "GET",
                url: url,
                //dataType: "json",
                //data: data //{ name: "query", colors: "Red" }
            })
                .done(function( msg ) {
                    //alert( "Data Saved: " + msg["ajax"] );
                    //$("#products").html(msg);
                    //console.log(msg);
                }).error(function( msg ) {
                    //alert( "error: " + msg["ajax"] );
                });

        }

        $("#lsidebar input[type='checkbox']").change(function() {

            //make_url_for_ajax_call(); //commented/disabled, because in backend don't detected/exist in params["param_name"]

            var data = $('form#form_filters').serializeJSON();
            $("#btnFilter").click();

//            var items = $("#lsidebar input:checkbox:checked");
//            $.each(items, function(index, item) {
//                var selector = $(item);
//                console.log(index+") status:"+selector.is(":checked")+" val:"+selector.val()+" id:"+selector.attr("id"))
//            });
        });

        function init() {
            $("#product_details img").load(function () {
                var paddingTop = 40;
                var heightOfLeftSidebar = $("#lsidebar").height();
                var heightProductDetails = $("#product_details").height();
                var heightProducts = heightOfLeftSidebar - heightProductDetails - paddingTop;
                //console.log("hLS:" + heightOfLeftSidebar + " - hPDetails:" + heightProductDetails + "=" + heightProducts);
                $("#products.products").css('height', heightProducts);


                var heightOfItemsILike = $("#lsidebar").height() - $(".search_by_sku").height() -
                    $(".rsidebar_products_i_like h4").height() - $(".rsidebar_product_selected").height() - 80;//- paddingTop - 20;
                $(".products_liked").css('height', heightOfItemsILike);
             });

        };

    });
}).call(this);

