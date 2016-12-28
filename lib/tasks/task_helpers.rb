# Put helpers for rake tasks here
module TaskHelper

  # Sets up a report based on the passed report hash parameters. Code taken from common_seeds.rb
  def setup_report rep_hash
    puts "Creating report for: #{rep_hash.ai}"

    # Need to correctly handle updating active state; match everything except that.
    is_active = rep_hash[:active]
    rep_hash.delete :active
    report = Report.unscoped.find_or_create_by!(rep_hash)
    report.update_attributes(active: is_active)

    puts "Creating translations for #{rep_hash[:name]}..."
    locale = Locale.find_or_create_by!(name: "en")
    translation_key = TranslationKey.find_or_create_by!(name: rep_hash[:class_name])

    Translation.find_or_create_by!(translation_key_id: translation_key.id, locale_id: locale.id, value: rep_hash[:name] + " Report")

    puts "Internationalizing report name..."
    I18n.available_locales.reject{|x| x == :en}.each do |l|
      locale = Locale.find_or_create_by!(name: l.to_s)
      translation_key = TranslationKey.find_or_create_by!(name: rep_hash[:class_name])
      translation_value = "[#{l}]#{rep_hash[:name]} Report[/#{l}]"
      Translation.find_or_create_by!(translation_key_id: translation_key.id, locale_id: locale.id, value: translation_value)
    end
  end

end
