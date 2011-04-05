module Rails3JQueryAutocomplete

  # Contains utility methods used by autocomplete
  module Helpers

    #
    # Returns a hash with three keys actually used by the Autocomplete jQuery-ui
    # Can be overriden to show whatever you like
    # Hash also includes a key/value pair for each method in extra_data
    #
    def json_for_autocomplete(items, method, extra_data = nil)
      items.collect do |item|
        hash = {"id" => item.id, "label" => item.send(method), "value" => item.send(method)}
        extra_data.each do |datum|
          hash[datum] = item.send(datum)
        end if extra_data
        hash
      end
    end

    # Returns parameter model_sym as a constant
    #
    #   get_object(:actor)
    #   # returns a Actor constant supposing it is already defined
    #
    def get_object(model_sym)
      object = model_sym.to_s.camelize.constantize
    end

    def get_parent(parent_class_name)
      if parent_id = params[:id]
        parent_class_name = parent_class_name || params[:controller].singularize
        begin
          parent_model = get_object(parent_class_name)
        rescue
          raise "Couldn't find any ActiveRecord model with name: #{parent_class_name}. Please indicate a valid model name via the :parent_class_name option."
        end
        parent_model.find(parent_id)
      end
    end

    # Returns a symbol representing what implementation should be used to query
    # the database and raises *NotImplementedError* if ORM implementor can not be found
    def get_implementation(object)
      ancestors_ary = object.ancestors.collect(&:to_s)
      if ancestors_ary.include?('ActiveRecord::Base')
        :activerecord
      elsif ancestors_ary.include?('Mongoid::Document')
        :mongoid
      else
        raise NotImplementedError
      end
    end

    #DEPRECATED
    def get_order(implementation, method, options)
      warn 'Rails3JQueryAutocomplete#get_order is has been DEPRECATED, please use #get_autocomplete_order instead'
      get_autocomplete_order(implementation, method, options)
    end

    # Returns the order parameter to be used in the query created by get_items
    def get_autocomplete_order(implementation, method, options)
      order = options[:order]

      case implementation
        when :mongoid then
          if order
            order.split(',').collect do |fields|
              sfields = fields.split
              [sfields[0].downcase.to_sym, sfields[1].downcase.to_sym]
            end
          else
            [[method.to_sym, :asc]]
          end
        when :activerecord then
          order || "#{method} ASC"
      end
    end

    # DEPRECATED
    def get_limit(options)
      warn 'Rails3JQueryAutocomplete#get_limit is has been DEPRECATED, please use #get_autocomplete_limit instead'
      get_autocomplete_limit(options)
    end

    # Returns a limit that will be used on the query
    def get_autocomplete_limit(options)
      options[:limit] ||= 10
    end

    # DEPRECATED
    def get_items(parameters)
      warn 'Rails3JQueryAutocomplete#get_items is has been DEPRECATED, you should use #get_autocomplete_items instead'
      get_autocomplete_items(parameters)
    end

    # Return the filtered model
    def get_autocomplete_filters(model, options)
      if options[:filters]
        model = model.where(options[:filters])
      end
      model
    end

    #
    # Can be overriden to return or filter however you like
    # the objects to be shown by autocomplete
    #
    #   items = get_autocomplete_items(:model => get_object(object), :options => options, :term => term, :method => method)
    #
    def get_autocomplete_items(parameters)
      model = relation = parameters[:model]
      method = parameters[:method]
      options = parameters[:options]
      term = parameters[:term]
      parent = parameters[:parent]
      is_full_search = options[:full]

      limit = get_autocomplete_limit(options)
      implementation = get_implementation(model)
      order = get_autocomplete_order(implementation, method, options)
      model = get_autocomplete_filters(model, options)
      all_scopes = [(options[:scope] || options[:scopes])].flatten.compact
      have_scope = all_scopes.any?


      if parent
        relation_name = options[:relation_name] || model.name.underscore.pluralize
        initial_scope = parent.send(relation_name)
      else
        initial_scope = model
      end
      if have_scope
        # If we use a scope the order should be done in this scope.
        last_scope = all_scopes.pop
        if all_scopes.any?
          scopes_items = all_scopes.inject(initial_scope){|working_scope, new_scope| working_scope.send(new_scope.to_sym)}
        else
          scopes_items = initial_scope
        end
        items = scopes_items.send(last_scope.to_sym, term, method).limit(limit)
      else
        case implementation
        when :mongoid
          order_method = "order_by"
          search = (is_full_search ? '.*' : '^') + term + '.*'
          where_clause = {method.to_sym => /#{search}/i}
        when :activerecord
          relation = model.select([:id, method] + (options[:extra_data].blank? ? [] : options[:extra_data])) unless options[:full_model]
          items = relation.where(["LOWER(#{method}) LIKE ?", "#{(is_full_search ? '%' : '')}#{term.downcase}%"]) \
            .limit(limit).order(order)
        end
      end
    end
  end
end
