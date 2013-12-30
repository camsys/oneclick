class EspReader

  DELIMITER='::'
  MDB_FILE='~/Downloads/ESPTEST/melton_esptest1222013.MDB'

  def run
    table = {}
    ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"].each do |t|
      tempfile = Tempfile.new("#{t}.csv")
      begin
        # TODO input MDB file needs to be parameterized
        `mdb-export -R '||' -b raw db/arc/melton_esptest1222013.MDB #{t} | dos2unix > #{tempfile.path}`
        table[t] = to_csv tempfile
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
    table
  end


  def slurp file
    whole_file = file.read
    whole_file.split '||'
  end

  def to_csv file
    slurp(file).collect do |row|
      CSV.parse(row).flatten
    end
  end

end
