module CustomHelper

  def render_dynamic_index(model_name, attribute_name, not_special_attrib, special_attrib, opts = {})
    @attribute_names = []
    @special = []
    @not_special = []
    @opts = opts
    attribute_name.each do |attrib|
      @attribute_names << t("views.#{model_name.to_s.underscore+"s"}.index.attributes.#{attrib}")
    end
    not_special_attrib.each do |attrib|
      @not_special << attrib
    end  
    special_attrib.each do |attrib|
      @special << attrib
    end if special_attrib.present?
    concat(render(:partial => 'layouts/index'))
  end

end  