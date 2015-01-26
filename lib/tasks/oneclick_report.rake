#encoding: utf-8
namespace :oneclick do
  namespace :report do
    desc "Enable Standard Usage Report "
    task enable_standard_usage_report: :environment do

      if Report.where(class_name: 'StandardUsageReport').count == 0
        Report.create({
          name: "Standard Usage Report", 
          description: "Overall system usage standard statistics", 
          view_name: "standard_usage_report", 
          class_name: "StandardUsageReport", 
          active: true, 
          exportable: true
        })

        puts 'Standard Usage Report enabled.'
      end
    end # task
  end
end
