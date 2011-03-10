module Rails3JQueryAutocomplete
  module TestCase
    module ActiveRecord
      def setup
        ::ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
        ::ActiveRecord::Schema.define(:version => 1) do
          create_table :movies do |t|
            t.column :name, :string
            t.column :movie_type, :string
            t.column :year, :string
          end
        end

        create_models

        @controller = ActorsController.new

        @movie1 = @movie_class.create(:name => 'Alpha', :movie_type => 'Comedy', :year => "1969")
        @movie2 = @movie_class.create(:name => 'Alspha', :movie_type => 'Drama', :year => "2010")
        @movie3 = @movie_class.create(:name => 'Alzpha', :movie_type => 'Porn', :year => "1942")
      end

      def teardown
        destroy_models
        ::ActiveRecord::Base.connection.tables.each do |table|
          ::ActiveRecord::Base.connection.drop_table(table)
        end
      end

      private
      def create_models
        @movie_class = Object.const_set(:Movie, Class.new(::ActiveRecord::Base))
        @movie_class.class_eval do
          def display_name
            "Movie: #{name}"
          end
        end
      end

      def destroy_models
        Object.send(:remove_const, :Movie)
      end

    end
  end
end
