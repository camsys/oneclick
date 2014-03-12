require 'spec_helper'

describe AgencyUserRelationship do
    describe "responds to relationship methods" do
        it { should respond_to(:revokable) }
        it { should respond_to(:retractable) }
        it { should respond_to(:acceptable) }
        it { should respond_to(:declinable) }
        it { should respond_to(:hidable) }
    end

    
end
