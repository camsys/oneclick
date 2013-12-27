# ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"]
module Esp
  class Provider < ActiveMDB::Base
    set_mdb_file '/Users/dhaskin/Downloads/ESPTEST/melton_esptest1222013.MDB'
    set_table_name 'tProvider'
  end
end
