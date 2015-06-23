class Admin::TranslationsController < Admin::BaseController

    authorize_resource

    def index
      @locales = Locale.all
      @translation_keys = TranslationKey.order(:name)
      render 'index' 
    end

    def new
        locale = Locale.find_by_name(params[:key_locale])
        @translation = Translation.new(key: params[:key] || nil, locale: locale || nil)
    end

    def create
        #same form is used to create new keys as well as new translations with existing keys
        locale = Locale.find_by_name(trans_params["locale"])
        translation_key = TranslationKey.find_or_create_by!(name: trans_params["key"])
        @translation = Translation.new
        @translation.value = trans_params["value"]
        @translation.locale = locale
        @translation.translation_key = translation_key
        if @translation.save
            flash[:success] = "Translation Successfully Saved"
            redirect_to admin_translations_path
        else
            flash[:alert] = "Error creating translation."
            render 'new'
        end
    end

    def edit
        @translation = Translation.find_by_id params[:id]
    end

    def update
        @translation = Translation.find_by_id params[:id]

        translation_key = TranslationKey.find_by_name(trans_params["key"])

        @translation.value = trans_params["value"]
        @translation.translation_key = translation_key

        if @translation.save
            flash[:success] = "Translation Successfully Updated"
            redirect_to admin_translations_path
        else
            render 'edit'
        end
    end

    def destroy
        translation_key_id = params[:id].to_s
        translations = Translation.where(translation_key_id: translation_key_id)
        translations.each do |translation|
            translation.destroy
        end
        flash[:success] = "Translation Removed"
        redirect_to admin_translations_path
    end

    private

        def trans_params
            params.require(:translation).permit(:key, :locale, :value)
        end

end
