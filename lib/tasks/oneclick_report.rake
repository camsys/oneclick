#encoding: utf-8
namespace :oneclick do
  namespace :report do
    desc "Enable Standard Usage Report "
    task enable_standard_usage_report: :environment do

      if Report.where(class_name: 'StandardUsageReport').count == 0
        rep = {
          name: "Standard Usage Report", 
          description: "Overall system usage standard statistics", 
          view_name: "standard_usage_report", 
          class_name: "StandardUsageReport", 
          active: true, 
          exportable: true
        }
        Report.create(rep)

        # StandardUsagerReport translations
        Translation.find_or_create_by!(key: rep[:class_name], locale: :en, value: rep[:name])
        I18n.available_locales.reject{|x| x == :en}.each do |l|
          Translation.find_or_create_by!(key: rep[:class_name], locale: l, value: "[#{l}]#{rep[:name]}[/#{l}]")
        end

        puts 'Standard Usage Report enabled.'
      end
    end # task
  end
end
