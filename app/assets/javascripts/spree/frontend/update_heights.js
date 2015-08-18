/* This script:
 + is updating a heights for the right sidebar and the product viewer according to height of the left sidebar;
 + Show/Display following fields: price, sku, like and select buttons, when we will hover on a product.
 */

update_heights();


//$("#product_details img").load(function () {
//    update_heights();
//});

function update_heights() {

    //update height of the products partial
    var paddingTop = 40;
    var heightOfLeftSidebar = $("#lsidebar").height();
    var heightProductDetails = $("#product_details").height();
    var heightProducts = heightOfLeftSidebar - heightProductDetails - paddingTop;
    //console.log("hLS:" + heightOfLeftSidebar + " - hPDetails:" + heightProductDetails + "=" + heightProducts);
    $("#products.products").css('height', heightProducts);

    //update height of the right sidebar
    var heightOfItemsILike = $("#lsidebar").height() - $(".search_by_sku").height() -
        $(".rsidebar_products_i_like .panel-heading").height() - $(".rsidebar_product_selected").height() - 80;
    $(".products_liked").css('height', heightOfItemsILike);


};

// onHover() event for product list
$('.products .btn').hide();
$('.products .sku').hide();
$('.products .price').hide();
$("#products.products").
    on('mouseenter', ".product-list-item", function () {
        var item = $(this);
        item.find(".btn").show();
        item.find(".sku").show();
        item.find(".price").show();
//            console.log('hovering');
    }).on('mouseleave', '.product-list-item', function () {
        var item = $(this);
        item.find(".btn").hide();
        item.find(".sku").hide();
        item.find(".price").hide();
//            console.log("mouseleave");
    });

$(".products #btn_select").on('click', function() {
    var parent = $(this).parents(".product-list-item");
    $(".rsidebar_products_i_like .product-list-item").before(parent);
});

$(".products #btn_like").on('click', function() {
    var parent = $(this).parents(".product-list-item");
    parent.find("#btn_like").hide();
    parent.find(".sku").hide();
    parent.find(".price").hide();
    //$(".rsidebar_products_i_like .product-list-item").before(parent); # for no jquery script
    $(".rsidebar_products_i_like .products_liked").prepend(parent);

});