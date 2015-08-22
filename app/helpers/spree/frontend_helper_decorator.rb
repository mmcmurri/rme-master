Spree::FrontendHelper.class_eval do

  def taxons_tree_with_filters(root_taxon, current_taxon, max_level)
    max_level = 2 #max_level.present? ? max_level : 1
    return '' if max_level < 1 || root_taxon.leaf?
    root_taxon.children.map do |taxon|
      input = text_field_tag nil, taxon.name, class: 'form-control', readonly: true
      check_box = content_tag :span, class: 'input-group-addon' do
        check_box_tag 'categories[]', taxon.name, false, disabled: false, id: taxon.id
      end
      content_tag :div, class: 'input-group' do
        input + check_box
        # css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'list-group-item active' : 'list-group-item'
        # link_to(taxon.name, seo_url(taxon), class: css_class) + taxons_tree(taxon, current_taxon, max_level - 1)
      end
    end.join("\n").html_safe
  end


  def taxons_tree_with_filters(taxonomy)
    taxonomy.taxons.map do |taxon|
      if !taxon.parent_id.nil?
        input = text_field_tag nil, taxon.name, class: 'form-control', readonly: true
        check_box = content_tag :span, class: 'input-group-addon' do
          check_box_tag 'categories[]', taxon.id, false, disabled: false, id: "category-#{taxon.id}"
        end
        content_tag :div, class: 'input-group' do
          input + check_box
        end
      end
    end.join("\n").html_safe
  end


end

