require 'spec_helper'

describe 'user' do
 it { expect { visit '/users/' }.to_not raise_error }
end
