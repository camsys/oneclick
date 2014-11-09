module Rails
  class Application
    class Configuration

      def method_missing(name, *args, &blk)

        begin
          db_config = OneclickConfiguration.where(code: name).first
        rescue
          super
        end

        if db_config
          return db_config.value
        elsif @@options.key?(name)
          # It's already been defined, just get it
          return @@options[name]
        else
          super
        end
      end
    end
  end
end