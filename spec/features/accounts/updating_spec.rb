require 'rails_helper'
require 'multitenacy/testing_support/factories/account_factory'
require 'multitenacy/testing_support/factories/plan_factory'
require 'multitenacy/testing_support/authentication_helpers'

feature 'Accounts' do
  include Multitenacy::TestingSupport::AuthenticationHelpers
  let(:account){ FactoryGirl.create(:account) }
  let(:root_url) { "http://#{account.subdomain}.example.com/"}
  let(:query_string){ Rack::Utils.build_query(
      plan_id: extreme_plan.id,
      http_status: 200,
      id: 'a_fake_id',
      kind: 'create_customer',
      hash: '<hash>'
  )}

  context 'as the account owner' do
    before do
      sign_in_as(user: account.owner, account: account)
    end

    scenario 'updating an account' do
      visit root_url
      click_link 'Edit Account'
      fill_in 'Name', with: 'A new name'
      click_button 'Update Account'
      expect(page).to have_content('Account updated successfully.')
      expect(account.reload.name).to eq 'A new name'
    end

    scenario 'update account with invalid attributes' do
      visit root_url
      click_link 'Edit Account'
      fill_in 'Name', with: ''
      click_button 'Update Account'
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Account could not be updated.")
    end
  end

  context 'as a normal user' do
    before do
      user = FactoryGirl.create(:user)
      sign_in_as(user: user, account: account)
    end

    scenario "Cannot edit account's information" do
      visit multitenacy.edit_account_url(subdomain: account.subdomain)
      expect(page).to have_content('You are not allowed to do that.')
    end
  end

  context 'with plans' do
    let!(:starter_plan){ FactoryGirl.create(:plan, price: 9.99, braintree_id: 'starter', name: 'Starter')}
    let!(:extreme_plan){ FactoryGirl.create(:plan, price: 19.99, braintree_id: 'extreme', name: 'Extreme')}
    before do
      account.update(plan_id: starter_plan.id)
      sign_in_as(user: account.owner, account: account)
    end
    scenario "updating an account's plan" do
      mock_transparent_redirect_response = double(success?: true)
      allow(mock_transparent_redirect_response).to receive_message_chain(:customer, :credit_cards).and_return [double(token: 'abcdef')]
      expect(Braintree::TransparentRedirect).to receive(:confirm).and_return mock_transparent_redirect_response
      subscription_params = {payment_method_token: 'abcdef', plan_id: extreme_plan.braintree_id}
      subscription_result = double(success?: true, subscription: double(id: 'abc123'))
      expect(Braintree::Subscription).to receive(:create).with(subscription_params).and_return subscription_result
      visit root_url
      click_link 'Edit Account'
      select 'Extreme', from: 'Plan'
      click_button 'Update Account'
      expect(page).to have_content("Account updated successfully.")
      plan_url = multitenacy.plan_account_url(plan_id: extreme_plan.id, subdomain: account.subdomain)
      expect(page.current_url).to eq plan_url
      expect(page).to have_content "You are changing to 'Extreme' plan"
      expect(page).to have_content "This plan costs 19.99 per month"
      fill_in 'Credit card number', with: '4111111111111111'
      fill_in 'Name on card', with: 'Dummy user'
      future_date = "#{Time.now.month + 1}/#{Time.now.year + 1}"
      fill_in 'Expiration date', with: future_date
      fill_in 'CVV', with: '123'
      click_button 'Change plan'
      expect(page).to have_content("You have switched to 'Extreme' plan.")
      expect(page.current_url).to eq root_url
      expect(account.reload.braintree_subscription_id).to eq 'abc123'
    end

    scenario "cannot change account's plan with invalid card number" do
      message = 'Credit card number must be 12-19 digits'
      expect(Braintree::TransparentRedirect).to receive(:confirm).and_return(double(success?: false, message: message))
      visit root_url
      click_link 'Edit Account'
      select 'Extreme', from: 'Plan'
      click_button 'Update Account'
      expect(page).to have_content("Account updated successfully.")
      plan_url = multitenacy.plan_account_url(plan_id: extreme_plan.id, subdomain: account.subdomain)
      expect(page.current_url).to eq plan_url
      expect(page).to have_content "You are changing to 'Extreme' plan"
      expect(page).to have_content "This plan costs 19.99 per month"
      fill_in 'Credit card number', with: '1'
      fill_in 'Name on card', with: 'Dummy user'
      future_date = "#{Time.now.month + 1}/#{Time.now.year + 1}"
      fill_in 'Expiration date', with: future_date
      fill_in 'CVV', with: '123'
      click_button 'Change plan'
      expect(page).to have_content('Invalid credit card details. Please try again.')
      expect(page).to have_content(message)
    end

    scenario 'changing plan after initial subscription' do
      account.update_column(:braintree_subscription_id, 'abc123')
      expect(Braintree::Subscription).to receive(:update).with(account.braintree_subscription_id, plan_id: extreme_plan.braintree_id).and_return(double(success?: true))
      visit root_url
      click_link 'Edit Account'
      select 'Extreme', from: 'Plan'
      click_button 'Update Account'
      expect(page).to have_content "You are changing to 'Extreme' plan"
      expect(page).to have_content "This plan costs 19.99 per month"
      click_button 'Change plan'
      expect(page).to have_content("You have switched to the 'Extreme' plan")
      expect(page.current_url).to eq root_url
      expect(account.reload.plan).to eq extreme_plan
    end

    scenario 'changing plan after initial subscription - fail case' do
      account.update_column(:braintree_subscription_id, 'abc123')
      expect(Braintree::Subscription).to receive(:update).with(account.braintree_subscription_id, plan_id: extreme_plan.braintree_id).and_return(double(success?: false))
      visit root_url
      click_link 'Edit Account'
      select 'Extreme', from: 'Plan'
      click_button 'Update Account'
      expect(page).to have_content "You are changing to 'Extreme' plan"
      expect(page).to have_content "This plan costs 19.99 per month"
      click_button 'Change plan'
      expect(page).to have_content("Something went wrong. Please try again.")
    end
  end
end