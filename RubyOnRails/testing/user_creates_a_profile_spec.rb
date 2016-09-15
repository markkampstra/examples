require 'rails_helper'

feature 'User creates a profile' do
  scenario 'they see the created profile on the screen' do
    visit new_user_registration_path

    fill_in 'Your name / alias', with: 'John Doe'
    fill_in 'E-mail', with: 'john@doe.com'
    fill_in 'Password', with: 'secret1234'
    fill_in 'Password confirmation', with: 'secret1234'
    click_button 'Sign up!'
    
    expect(page).to have_content "John Doe's timeline"
  end
  
  scenario 'they see an error when the password is too short' do
    visit new_user_registration_path

    fill_in 'Your name / alias', with: 'John Doe'
    fill_in 'E-mail', with: 'john@doe.com'
    fill_in 'Password', with: '123'
    fill_in 'Password confirmation', with: '123'
    click_button 'Sign up!'

    expect(page).to have_content "Password is too short"
  end
    
  scenario 'they see an error when an e-mailaddress is already taken' do
    visit new_user_registration_path

    fill_in 'Your name / alias', with: 'John Doe'
    fill_in 'E-mail', with: 'john@doe.com'
    fill_in 'Password', with: 'secret1234'
    fill_in 'Password confirmation', with: 'secret1234'
    click_button 'Sign up!'

    expect(page).to have_content "John Doe's timeline"
    click_link 'Sign out'

    expect(page).to have_content "Signed out successfully."

    visit new_user_registration_path

    fill_in 'Your name / alias', with: 'John Doe'
    fill_in 'E-mail', with: 'john@doe.com'
    fill_in 'Password', with: 'secret1234'
    fill_in 'Password confirmation', with: 'secret1234'
    click_button 'Sign up!'

    expect(page).to have_content "Email has already been taken"
  end
end

feature 'User follows other user' do
  scenario 'they see followers and following on their profile' do
    # Create John Doe profile
    visit new_user_registration_path
    fill_in 'Your name / alias', with: 'John Doe'
    fill_in 'E-mail', with: 'john@doe.com'
    fill_in 'Password', with: 'secret1234'
    fill_in 'Password confirmation', with: 'secret1234'
    click_button 'Sign up!'

    expect(page).to have_content "John Doe's timeline"

    click_link 'Sign out'
    
    # Create Jane Doe profile
    visit new_user_registration_path

    fill_in 'Your name / alias', with: 'Jane Doe'
    fill_in 'E-mail', with: 'jane@doe.com'
    fill_in 'Password', with: 'secret1234'
    fill_in 'Password confirmation', with: 'secret1234'
    click_button 'Sign up!'

    expect(page).to have_content "Jane Doe's timeline"

    click_link 'my profile'
    click_link 'Follow John Doe'
    
    # Check Following list
    expect(page).to have_css '#following', text: "John Doe"
    
    click_link 'Sign out'
    visit new_user_registration_path
    fill_in 'sign_in_email', with: 'jane@doe.com'
    fill_in 'sign_in_password', with: 'secret1234'
    
    click_button 'Sign in'
    save_page
    click_link 'my profile'
    
    # Check Following list
    expect(page).to have_content 'Unfollow John Doe'


    click_link 'Unfollow John Doe'
    
    expect(page).to have_content 'Follow John Doe'
  end
end