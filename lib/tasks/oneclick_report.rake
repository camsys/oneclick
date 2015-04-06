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

    desc "Seed supported filter types in reporting engine "
    task seed_reporting_filter_types: :environment do

      %w(
        eq not_eq 
        matches does_not_match 
        lt gt 
        lteq gteq 
        in not_in 
        cont not_cont 
        cont_any not_cont_any 
        i_cont i_not_cont
        start not_start
        end not_end
        true not_true
        false not_false
        present blank
        null not_null
        range
        select
        multi_select
        ).each do |type|
        Reporting::ReportingFilterType.where(name: type).first_or_create
      end
      puts 'Finished seeding reporting filter types.'

    end # task
  end
end
