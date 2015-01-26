class Admin::TranslationsController < Admin::BaseController
    include LocaleHelpers
    authorize_resource

    def index
      @locales = I18n.available_locales      
      @translations_proxies = []
      translation_keys = Translation.uniq.pluck(:key).sort{|a, b| a.downcase <=> b.downcase} ## Get list of unique keys
      translation_keys.each do |k|
          @translations_proxies << TranslationProxy.new(key: k, translations: Translation.where("key = ?", k))    ## Build proxies with key mapping to its locales
      end
      render 'index' 
    end

    def new
        @translation = Translation.new(key: params[:key] || nil, locale: params[:key_locale] || nil)
    end

    def create
        @translation = Translation.new(trans_params)
        if @translation.save
            flash[:success] = "Translation Successfully Saved"
            redirect_to admin_translations_path
        else
            render 'new'
        end
    end

    def edit
        @translation = Translation.find_by_id params[:id]
    end

    def update
        @translation = Translation.find_by_id params[:id]
        if @translation.update_attributes trans_params
            flash[:success] = "Translation Successfully Updated"
            redirect_to admin_translations_path
        else
            render 'edit'
        end
    end

    def destroy
        ids = [params[:id].to_i, params[:second_translation].to_i]
        ids.each do |id|
            unless id == 0
                Translation.find(id).destroy
            end
        end
        flash[:success] = "Translation Removed"
        redirect_to admin_translations_path
    end

    private

        def trans_params
            params.require(:translation).permit(:key, :locale, :value)
        end

end
