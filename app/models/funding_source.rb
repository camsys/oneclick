class FundingSource < ActiveRecord::Base

  #used to rank funding sources allowed for each booking service

  belongs_to :service

  #code: funding source identifier e.g., MATA, ADA, ADAYORK, etc.
  #index: integer used to rank funding sources in order of preference.


 end