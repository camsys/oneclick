class Admin::TranslationsController < Admin::BaseController

    authorize_resource

    def index
        @locales = I18n.available_locales.sort

        translations = Translation.includes(:locale, :translation_key).references(:locale, :translation_key)
            .where.not(translation_key_id: nil)
            .where(locales: {name: I18n.available_locales}).order("translation_keys.name asc", "locales.name asc")

        empty_locale_hash = Hash.new
        @locales.each {|l| empty_locale_hash[l] = nil}

        @translations_hash = Hash.new
        translations.find_each do |t|
            key_name = t.translation_key.name
            @translations_hash[key_name] ||= empty_locale_hash.clone
            @translations_hash[key_name][t.locale.name] = {
                id: t.id,
                value: t.value
            }
        end

        @translation_keys = @translations_hash.keys

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

        #check for existing translation
        existing_translation = Translation.where("locale_id = #{locale.id} AND translation_key_id = #{translation_key.id}")

        if existing_translation.count > 0
            flash[:alert] = "Error: that translation already exists."
            redirect_to admin_translations_path and return
        else
            @translation = Translation.new
            @translation.value = trans_params["value"]
            @translation.locale = locale
            @translation.translation_key = translation_key
        end

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

        @translation.value = trans_params["value"]

        Rails.logger.info "Saving translation.  Params = "
        Rails.logger.info params

        if @translation.save
            flash[:success] = "Translation Successfully Updated"
            redirect_to admin_translations_path
        else
            begin
                @translation.save!
            rescue Exception => e
                Rails.logger.info "Exception saving translation"
                Rails.logger.info e 
            end
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
