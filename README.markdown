# rails3-jquery-autocomplete

An easy way to use jQuery's autocomplete with Rails 3.

Supports both ActiveRecord and [mongoid](http://github.com/mongoid/mongoid).

Works with [Formtastic](http://github.com/justinfrench/formtastic)
and [SimpleForm](https://github.com/plataformatec/simple_form)

## ActiveRecord

You can find a [detailed example](http://github.com/crowdint/rails3-jquery-autocomplete-app)
on how to use this gem with ActiveRecord [here](http://github.com/crowdint/rails3-jquery-autocomplete-app).

## MongoID

You can find a [detailed example](http://github.com/crowdint/rails3-jquery-autocomplete-app/tree/mongoid)
on how to use this gem with MongoID [here](http://github.com/crowdint/rails3-jquery-autocomplete-app/tree/mongoid). (Same thing, different branch)

## Before you start

Make sure your project is using jQuery-ui with the autocomplete widget
before you continue.

You can find more info about that here:

* http://jquery.com/
* http://jqueryui.com/demos/autocomplete/
* http://github.com/rails/jquery-ujs

I'd encourage you to understand how to use those 3 amazing tools before attempting to use this gem.

## Installing

Include the gem on your Gemfile

    gem 'rails3-jquery-autocomplete'

Install it

    bundle install

Run the generator

    rails generate autocomplete

And include autocomplete-rails.js on your layouts

    javascript_include_tag "autocomplete-rails.js"

## Upgrading from older versions

If you are upgrading from a previous version, run the generator after installing to replace the javascript file.

    rails generate autocomplete

I'd recommend you do this every time you update to make sure you have the latest JS file.

## Usage

### Model Example

Assuming you have a Brand model:

    class Brand < ActiveRecord::Base
    end

    create_table :brand do |t|
      t.column :name, :string
    end

### Controller

To set up the required action on your controller, all you have to do is call it with the class name and the method
as in the following example:

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name
    end

This will create an action _autocomplete_brand_name_ on your controller, don't forget to add it on your routes file

    resources :products do
      get :autocomplete_brand_name, :on => :collection
    end

This example will display all the brands that have a name matching the pattern you specify in your autocomplete text-field

### Limit the results based on the model relations:

Imagine we have a Product and a Brand model linked by a 'has_many' relation:

    class Brand < ActiveRecord::Base
      has_many :products
    end

    class Product < ActiveRecord::Base
      belongs_to :brand
    end

In the show view of the BrandsController you have a search_field used to find a product of the current brand object.
You want this field to do autocompletion on the name attribute of the product model.
You don't want to querry on all the products existing in the database but only to the products that belongs to the current brand object.

To do that you first need to add the autocomplete action to your brand controller:

  class BrandsController < Admin::BaseController
    autocomplete :product, :name
  end

In your routes file you'll not add a "collection" but a "member" entry to the brands resources:

  resources :brands do
    get :autocomplete_product_name, :on => :member
  end

As this is a member route, the "autocomplete_product_name" method of your BrandController will get a params[:id].
The search will retreive the brand object thanks to this id and will only search for matching products within: brand.products

### Options

#### :full => true

By default, the search starts from the beginning of the string you're searching for. If you want to do a full search, set the _full_ parameter to true.

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :full => true
    end

The following terms would match the query 'un':

* Luna
* Unacceptable
* Rerun

#### :full => false (default behavior)

Only the following terms mould match the query 'un':

* Unacceptable

#### :parent_class_name

When you limit the results based on the model relations (see example above), the parent model name ('Brand' in the example) is guessed based on the name of the controller where you added the 'autocomplete' statement. (controller name: 'BrandsController' => model name: 'Brand').

If you don't have this naming convention for you model-controllers, you can pass the parent_class_name as a parameter:

  class BrandsController < Admin::BaseController
    autocomplete :product, :name, :parent_class_name => "MyBrand"
  end

The autocomplete_product_name method will then retreive the parent object with: MyBrand.find(params[:id])

#### :relation_name

When you limit the results based on the model relations (see example above), we use the name of the model on which you autocomplete to find the relation name:

  autocomplete :product, :name

Here, the model name is 'product', we assume then that the brand model has_many :products (the results will be filtered within brand.products)
But in the case you have a relation like:

  class Brand < ActiveRecord::Base
    has_many :nice_products, :class_name => "Product"
  end

Then brand.products will not work.
You then need to specify the :relation_name parameter:

  class BrandsController < Admin::BaseController
    autocomplete :product, :name, :relation_name => "nice_products"
  end

The results will then be filtered within: brand.nice_products

#### :extra_data

By default, your search will only return the required columns from the database needed to populate your form, namely id and the column you are searching (name, in the above example).

Passing an array of attributes/column names to this option will fetch and return the specified data.

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :extra_data => [:slogan]
    end

#### :display_value

If you want to display a different version of what you're looking for, you can use the :display_value option.

This options receives a method name as the parameter, and that method will be called on the instance when displaying the results.

    class Brand < ActiveRecord::Base
      def funky_method
        "#{self.name}.camelize"
      end
    end


    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :display_value => :funky_method
    end

In the example above, you will search by _name_, but the autocomplete list will display the result of _funky_method_

This wouldn't really make much sense unless you use it with the :id_element HTML tag. (See below)

<<<<<<< HEAD
#### :filter_params

You can specify an array of filters retrieved from controller params

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :filter_params => [:type, :category]
    end

This will automatically add {:type => params[:type], :category => params[:category]} to your request

#### :scope and :scopes

If you want the autocomplete results to be found based on a model scope instead of on a model attibute you can set the :scope or :scopes option.

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :scope => "a_scope", :display_value => :name
      #or
      autocomplete :brand, :name, :scopes => ["first_scope", "second_scope"], :display_value => :name
    end

The last scope we receive the 'term' value as parameter.

If you don't set the :display_value option, the second attribute will be use for the display value.
=======
Only the object's id and the column you are searching on will be returned in JSON, so if your display_value method requires another parameter, make sure to fetch it with the :extra_data option
>>>>>>> crowdint/master

### View

On your view, all you have to do is include the attribute autocomplete on the text field
using the url to the autocomplete action as the value.

    form_for @product do |f|
      f.autocomplete_field :brand_name, autocomplete_brand_name_products_path
    end

This will generate an HTML tag that looks like:

    <input type="text" data-autocomplete="products/autocomplete_brand_name">

If you are not using a FormBuilder (form_for) or you just want to include an autocomplete field without the form, you can use the
*autocomplete_field_tag* helper.

    form_tag 'some/path'
      autocomplete_field_tag 'address', '', address_autocomplete_path, :size => 75
    end

Or in the case of a "member" route (see: "Limit the results based on the model relations" above):

    form_tag 'some/path'
      autocomplete_field_tag 'search_product', '', autocomplete_product_name_brand_path(current_brand), :size => 75
    end

Now your autocomplete code is unobtrusive, Rails 3 style.

### Submit on select

Sometimes you may want your form to be submited as soon as you select an element in the autocomplete item list.
You just have to set the ':submit_on_select' option to true:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :submit_on_select => true

### Getting the object id

If you need to use the id of the selected object, you can use the *:id_element* HTML tag too:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :id_element => '#some_element'

This will update the field with id *#some_element with the id of the selected object. The value for this option can be any jQuery selector.

<<<<<<< HEAD
### Autocomplete widget options

The Jquery autocomplete widget allow the following options: 'disabled', 'appendTo', 'delay', 'minLength' and 'source' (see: http://docs.jquery.com/UI/Autocomplete#option-disabled)

You can define values for these options by adding HTML tags to your 'autocomplete_field' field in the view:

#### disabled

Disables (true) or enables (false) the autocomplete. Can be set when initialising (first creating) the autocomplete.

Default = false

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :autocomplete_disabled => true

If you disable de autocomplete when initialising, you'll probably want to enable it somewhere else in your javascript code:

Get or set the disabled option, after init:

    //getter
    var disabled = $( ".selector" ).autocomplete( "option", "disabled" );
    //setter
    $( ".selector" ).autocomplete( "option", "disabled", false );

#### appendTo

Which element the menu should be appended to.

Default: 'body'

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :append_to => '#another_ellement'

#### delay

The delay in milliseconds the Autocomplete waits after a keystroke to activate itself. A zero-delay makes sense for local data (more responsive), but can produce a lot of load for remote data, while being less responsive.

Default = 300

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :delay => 100

#### minLength

The minimum number of characters a user has to type before the Autocomplete activates. Zero is useful for local data with just a few items. Should be increased when there are a lot of items, where a single character would match a few thousand items.

Default = 2

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :min_length => 0

#### source

Defines the data to use.

The source options can obviously not be specified here since it is handled by this plugin itself.

### Customize the css of the result list

You can add custom css for the result list (ul, li, and/or a):


    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :result_list_css => {:ul => {:width => "100px"}, :li => {....}, :a => {:color => "red"}}.to_json

### Working client side

You also have the possibility to work client side. That mean that no remote action will be called and no query will be done in the DB.

If you work this way, you don't have to add anything to your controller (no "autocomplete" statment needed).
You then also don't need to add any route in your routes.yml config file.

In your view, the autocomplete_field will not take the url of a remote autocompletion method but the source elements for the autocompletion.

    f.autocomplete_field :brand_name, [{:id => "my_element_id", :label => "my_element_label", :value => "my_element_value", :for_search => "pattern_for_search"}].to_json , :no_remote => true

Don't forget to Jsonify your sources array.
As an example, here we directly put the sources array in our view but it is better to constuct it in your controller.

Also note that you can pass a :for_search element in your source hash. This will be the text use for the autocompletion query.

### Javascript on_select

If you want to persom some custom javascript when a user select an element in the autocomplete item list, you can add it via the :on_select option:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :on_select => "alert('Hello World')"
=======
### Getting extra object data

If you need to extra data about the selected object, you can use the *:update_elements* HTML attribute.

The :update_elements attribute accepts a hash where the keys represent the object attribute/column data to use to update and the values are jQuery selectors to retrieve the HTML element to update:

    f.autocomplete_field :brand_name, autocomplete_brand_name_products_path, :update_elements => {:id => '#id_element', :slogan => '#some_other_element'}

    class ProductsController < Admin::BaseController
      autocomplete :brand, :name, :extra_data => [:slogan]
    end

The previous example would fetch the extra attribute slogan and update jQuery('#some_other_element') with the slogan value.
>>>>>>> crowdint/master

## Formtastic

If you are using [Formtastic](http://github.com/justinfrench/formtastic), you automatically get the *autocompleted_input* helper on *semantic_form_for*:

    semantic_form_for @product do |f|
      f.autocompleted_input :brand_name, :url => autocomplete_brand_name_path
    end

The only difference with the original helper is that you must specify the autocomplete url using the *:url* option.

## SimpleForm

If you want to use it with simple_form, all you have to do is use the
:as option on the input and set the autocomplete path with the :url
option.


    simple_form_for @product do |form|
      form.input :name
      form.input :brand_name, :url => autocomplete_brand_name_path, :as => :autocomplete

# Cucumber

I have created a step to test your autocomplete with Cucumber and Capybara, all you have to do is add the following lines to your *env.rb* file:

    require 'cucumber/autocomplete'

Then you'll have access to the following step:

    I choose "([^"]*)" in the autocomplete list

An example on how to use it:

    @javascript
    Scenario: Autocomplete
      Given the following brands exists:
        | name  |
        | Alpha |
        | Beta  |
        | Gamma |
      And I go to the home page
      And I fill in "Brand name" with "al"
      And I choose "Alpha" in the autocomplete list
      Then the "Brand name" field should contain "Alpha"

I have only tested this using Capybara, no idea if it works with something else, to see it in action, check the [example app](http://github.com/crowdint/rails3-jquery-autocomplete-app).

# Development

If you want to make changes to the gem, first install bundler 1.0.0:

    gem install bundler

And then, install all your dependencies:

    bundle install

## Running the test suite

You need to have an instance of MongoDB running on your computer or all the mongo tests will fail miserably.

    rake test

## Integration tests

If you make changes or add features to the jQuery part, please make sure
you write a cucumber test for it.

You can find an example Rails app on the *integration* folder.

You can run the integration tests with the cucumber command while on the
integration folder:

    cd integration
    cucumber

# Changelog

* 0.6.2 SimpleForm plugin
* 0.6.1 Allow specifying fully qualified class name for model object as an option to autocomplete
* 0.6.0 JS Code cleanup
* 0.5.1 Add STI support
* 0.5.0 Formtastic support
* 0.4.0 MongoID support
* 0.3.6 Using .live() to put autocomplete on dynamic fields

# Thanks to

Everyone on [this list](https://github.com/crowdint/rails3-jquery-autocomplete/contributors)

# About the Author

[Crowd Interactive](http://www.crowdint.com) is an American web design and development company that happens to work in Colima, Mexico.
We specialize in building and growing online retail stores. We don’t work with everyone – just companies we believe in. Call us today to see if there’s a fit.
Find more info [here](http://www.crowdint.com)!
