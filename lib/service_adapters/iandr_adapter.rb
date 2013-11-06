module ServiceAdapters
  class IandrAdapter

    attr_accessor :providers

    def initialize(providers)
      @providers = providers
    end

    def to_xml(options = {})
      options[:skip_types] = true
      builder = options.delete(:builder) || Builder::XmlMarkup.new(options)
      builder.instruct!
      builder.interchange do |b|
        b.updated_at Time.now
        new_options = {builder: b, skip_instruct: true, skip_types: true,
          include: :services}.merge(options)
          puts new_options.inspect
        @providers.to_xml(new_options)
      end
    end

  end
end
