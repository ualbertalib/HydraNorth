require 'spec_helper'

describe Admin::BecomeController do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }
  
  context 'admin' do
    before do
      sign_in admin
    end

    it 'should become user' do
      get :index, id: user.email, use_route: :admin
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to be_blank
      expect(controller.current_user).to eq user
    end
    it 'should be warned if user is not specified' do
      get :index, use_route: :admin
      expect(flash[:alert]).to eq I18n.t('error.become_user')
    end
    it 'should be warned if user does not exist' do
      get :index, id: 'not_a_email', use_route: :admin
      expect(flash[:alert]).to eq I18n.t('error.become_user')
    end
  end

  it 'user should not become user' do
    sign_in other_user
    get :index, id: user.email, use_route: :admin
    expect(flash[:alert]).to eq I18n.t('unauthorized.become_user')
    expect(controller.current_user).to eq other_user
  end
  it 'anonymous should not become user' do
    get :index, id: user.email, use_route: :admin
    expect(flash[:alert]).to eq I18n.t('devise.failure.unauthenticated')
    expect(controller.current_user).to be_nil
  end
  
end
