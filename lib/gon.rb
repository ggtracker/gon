if defined?(Jbuilder)
  gem 'blankslate'
end
require 'action_view'
require 'action_controller'
require 'gon/base'
require 'gon/request'
require 'gon/helpers'
require 'gon/escaper'
if defined?(Rabl)
  require 'gon/rabl'
end
if defined?(Jbuilder)
  require 'gon/jbuilder'
end

module Gon
  class << self

    def method_missing(method, *args, &block)
      if ( method.to_s =~ /=$/ )
        if public_method_name? method
          raise "You can't use Gon public methods for storing data"
        end

        set_variable(method.to_s.delete('='), args[0])
      else
        get_variable(method.to_s)
      end
    end

    def all_variables
      Request.gon
    end

    def clear
      Request.clear
    end

    def rabl(*args)
      data, options = Gon::Rabl.handler(args)

      store_builder_data 'rabl', data, options
    end

    def jbuilder(*args)
      if RUBY_VERSION < '1.9'
        text = 'You can use Jbuilder support only in 1.9+'
        raise NoMethodError.new text
      end

      data, options = Gon::Jbuilder.handler(args)

      store_builder_data 'jbuilder', data, options
    end

    def inspect
      'Gon'
    end

    private

    def get_variable(name)
      Request.gon[name]
    end

    def set_variable(name, value)
      Request.gon[name] = value
    end

    def store_builder_data(builder, data, options)
      if options[:as]
        set_variable(options[:as].to_s, data)
      elsif data.is_a? Hash
        data.each do |key, value|
          set_variable(key, value)
        end
      else
        set_variable(builder, data)
      end
    end

    def public_method_name?(method)
      public_methods.include?(
        if RUBY_VERSION > '1.9'
          method.to_s[0..-2].to_sym
        else
          method.to_s[0..-2]
        end
      )
    end

  end
end
