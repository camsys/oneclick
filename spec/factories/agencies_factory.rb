FactoryGirl.define do
   #  Atlanta Regional Commission',
   # 'ARC Mobility Management',
   # 'ARC Agewise',
   # 'ARC Workforce Development',
   # 'Veterans Affairs',
   # 'Disability Link',
   # 'Cobb County Transit',
   # 'Goodwill Industries'

    factory :arc_agency, class: "agency" do
        name 'Atlanta Regional Commission'
        type "Agency"
    end
    factory :arc_mobility_mgmt_agency, :class => 'agency' do
        name 'ARC Mobility Management'
        type "Agency"
    end
    factory :va_agency, :class => 'agency' do
        name 'Veterans Affairs'
        type "Agency"
    end
    
end