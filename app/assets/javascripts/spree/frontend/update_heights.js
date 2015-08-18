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
$('.products .text').hide();
$('.products div.panel-heading').hide();
//$('.products .product_image_large').hide();

//$('.products #price').hide();
//$('.products #cart-form').hide();
//$('.products #cart-form #product-variants').hide();


$("#products.products").
    on('mouseenter', ".product-list-item", function () {
        var item = $(this);
        item.find('.btn').show();
        item.find('.sku').show();
        //item.find('.price').show();
        //item.find('#cart-form #price').show();

//            console.log('hovering');
    }).on('mouseleave', '.product-list-item', function () {
        var item = $(this);
        item.find('.btn').hide();
        item.find('.sku').hide();
        //item.find('#cart-form #price').hide();
//            console.log("mouseleave");
    });

// click on select button
$(".products #btn_select").on('click', function () {
    var parent = $(this).parents(".product-list-item");
    //$(".rsidebar_products_i_like .product-list-item").before(parent); # for no jquery script

    var productLiked = parent.clone();
    productLiked.find("#btn_like").hide();
    productLiked.find(".sku").hide();
    //productLiked.find(".price").hide();
    // add to products i like
    $(".rsidebar_products_i_like .products_liked").prepend(productLiked);

    var productSelected = parent.clone();
    productSelected.find("#btn_select").hide();
    productSelected.find("#btn_like").hide();
    //productSelected.find('#cart-form').show();
    //$('.products #cart-form .price').show();

    // add to selected product viewer
    $(".rsidebar_product_selected .product-list-item").replaceWith(productSelected);
    update_product_details(productSelected);

    product_selection_from_like_products();
});

// click on like button
$(".products #btn_like").on('click', function () {
    var parent = $(this).parents(".product-list-item").clone();
    parent.find("#btn_like").hide();
    parent.find(".sku").hide();
    //parent.find("#price").hide();
    //$(".rsidebar_products_i_like .product-list-item").before(parent); # for no jquery script
    $(".rsidebar_products_i_like .products_liked").prepend(parent);

    product_selection_from_like_products();
});

function product_selection_from_like_products() {
    $(".rsidebar_products_i_like #btn_select").on('click', function () {
        var parent = $(this).parents(".product-list-item");
        parent.find("#btn_select").hide();
        parent.find(".sku").show();
        $(".rsidebar_product_selected .product-list-item").replaceWith(parent);

        update_product_details(parent);
    });
}


function update_product_details(item) {
    var itemNew = item.clone();
    itemNew.find(".text").show();
    itemNew.find("img").hide();
    itemNew.find(".sku").hide();
    itemNew.find("a.info").hide();
    itemNew.find(".brand").show();
    itemNew.find(".panel-footer").hide();
    itemNew.find(".panel-heading").show();
    //itemNew.find('.product_details .product-list-item img').remove();

    $("#product_details.product_details").find(".product-list-item").replaceWith(itemNew);

    var urlToProduct = itemNew.find(".product_url").val();
    var urlToLargeImage = itemNew.find(".product_image_url").val();
    var image = '<img src="'+urlToLargeImage+'" class="product_image_large"/>';
    $("#product_details img.product_image_large").replaceWith(image);

    //var itemOld = $("#product_details.product_details").find(".product-list-item");
    //itemOld = itemNew;
    //itemOld.attr("class","col-md-14 col-sm-14 product-list-item");
    //itemOld.attr("id","col-md-14 col-sm-14 product-list-item");

}