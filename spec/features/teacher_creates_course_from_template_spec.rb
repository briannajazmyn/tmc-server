require 'spec_helper'

feature 'Teacher creates course from course template', feature: true do
  include IntegrationTestActions

  before :each do
    @organization = FactoryGirl.create :accepted_organization, slug: 'slug'
    @teacher = FactoryGirl.create :user, password: 'xooxer'
    @user = FactoryGirl.create :user, password: 'foobar'
    Teachership.create! user: @teacher, organization: @organization

    FactoryGirl.create :course_template, name: 'template', title: 'template', source_url: 'https://github.com/testmycode/tmc-testcourse.git'

    visit '/'
  end

  scenario 'Teacher succeeds at creating course with exercises' do
    log_in_as(@teacher.login, 'xooxer')

    visit '/org/slug'
    click_link 'Create New Course from template'
    click_link 'Create course'
    fill_in 'course_name', with: 'customname'
    fill_in 'course_title', with: 'Custom Title'
    fill_in 'course_description', with: 'Custom description'
    fill_in 'course_material_url', with: 'custommaterial.com'
    click_button 'Add Course'

    expect(page).to have_content('Course was successfully created')
    expect(page).to have_content('Custom Title')
    expect(page).to have_content('Custom description')
    expect(page).to have_link('http://custommaterial.com')
    expect(page).to have_content('help page')

    click_link 'View status page'
    expect(page).to have_content('arith_funcs')
    expect(page).to have_content('maven_exercise')

    visit '/org/slug/courses'
    expect(page).to have_content('Custom Title')
  end

  scenario 'Teacher doesnt succeed with invalid parameters' do
    log_in_as(@teacher.login, 'xooxer')

    visit '/org/slug'
    click_link 'Create New Course from template'
    click_link 'Create course'
    fill_in 'course_name', with: 'w h i t e s p a c e s'
    click_button 'Add Course'

    expect(page).to have_content('Name should not contain white spaces')
  end

  scenario 'Non-teacher doesnt succeed at creating course' do
    log_in_as(@user.login, 'foobar')

    visit '/org/slug'
    expect(page).not_to have_content('Create course from template')
  end
end