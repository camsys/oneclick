class SupportRoundTrips < ActiveRecord::Migration
  def change
    create_table :trip_parts do |t|
      
      # parent
      t.integer   :trip_id, :null => false
      # refs to trips places used as end points
      t.integer   :from_trip_place_id, :null => false
      t.integer   :to_trip_place_id, :null => false
      # ordering within a trip
      t.integer   :sequence, :null => false
      
      # date/time that this trip part is executed for. Could be arrive by or depart by. If the trip
      # part is a return trip the is_depart will always be true
      t.datetime  :trip_time, :null => false
      # determines if the trip time refers to arrival or depart time
      t.boolean   :is_depart, :default => false

      # true if it is a reverse trip (i.e. back to origin)
      t.boolean   :is_return_trip, :default => false
     
      t.timestamps
    end
    # itineraries are now associated with trip parts
    rename_column :itineraries, :planned_trip_id, :trip_part_id
    # trip parts are indexed by trip id and sequence
    add_index :trip_parts, [:trip_id, :sequence]
  end  
end
