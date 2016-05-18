require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the RecentHelper. For example:
#
# describe RecentHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe RecentHelper, type: :helper do
  let(:time) { Time.new(2016) }
  let(:bucket) { "2016-01-01T12:00:00Z" } 
  it { expect(floor(time, 1.year)).to eq '2016-01-01T12:00:00Z' }
  it { expect(ceil(time, 1.year)).to eq '2017-01-01T11:59:59Z' }
  it { expect(bucket_as_date(bucket)).to eq '2016: January' }
  it { expect(bucket_as_month(bucket)).to eq 'January' }
  it { expect(bucket_as_params(bucket)).to include(:year => 2016, :month => 1) }
end
