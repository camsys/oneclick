class TranslationProxy  
    include ActiveModel::Validations  
    include ActiveModel::Conversion  
    extend ActiveModel::Naming  
    
    attr_accessor :key, :translations
    # has_many :translations
   
    validates_presence_of :key

    def initialize(options = {})
        options.each do |name, value|  
            send("#{name}=", value)  
        end
  end

    def persisted?
        false
    end
end