module Rails3JQueryAutocomplete

  # Inspired on DHH's autocomplete plugin
  # 
  # Usage:
  # 
  # class ProductsController < Admin::BaseController
  #   autocomplete :brand, :name
  # end
  #
  # This will magically generate an action autocomplete_brand_name, so, 
  # don't forget to add it on your routes file
  # 
  #   resources :products do
  #      get :autocomplete_brand_name, :on => :collection
  #   end
  #
  # Now, on your view, all you have to do is have a text field like:
  # 
  #   f.text_field :brand_name, :autocomplete => autocomplete_brand_name_products_path
  #
  #
  # Additionnaly, you can specify an array of filters retrieved from controller params
  #
  # Usage :
  #
  # class ProductsController < Admin::BaseController
  #   autocomplete :brand, :name, :filter_params => [:type, :category]
  # end
  #
  # This will automatically add {:type => params[:type], :category => params[:category]} 
  # to your request
  #
  module ClassMethods
    def autocomplete(object, method, options = {})

      define_method("autocomplete_#{object}_#{method}") do

        # Extract params from controller instance
        # Prepare them for resquest
        if options[:filter_params]
          options[:filters] = {}
          options[:filter_params].each do |key|
            options[:filters][key] = self.params[key] if self.params[key]
          end
          options.delete(:filter_params)
        end

        term = params[:term]
        if term && !term.empty?
          #allow specifying fully qualified class name for model object
          class_name = options[:class_name] || object
          items = get_autocomplete_items(:model => get_object(class_name), \
            :options => options, :term => term, :method => method) 
        else
          items = {}
        end

        render :json => json_for_autocomplete(items, options[:display_value] ||= method)
      end
    end
  end
end
