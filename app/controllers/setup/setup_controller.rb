class Setup::SetupController < ApplicationController
  before_action :set_organization, :add_setup_breadcrumb

  STEPS =
    [
      {
        # step_number: 1,
        title: 'Template',
        path: :setup_organization_course_chooser_index
      },
      {
        # step_number: 2,
        title: 'Details',
        path: :edit_setup_organization_course_course_details_path
      },
      {
        # step_number: 3,
        title: 'Timing',
        path: :setup_organization_course_course_timing_path
      },
      {
        # step_number: 4,
        title: 'Assistants',
        path: :setup_organization_course_course_assistants
      },
      {
        # step_number: 5,
        title: 'Finish',
        path: nil
      }
    ].freeze

  def step_number(title)
    found = 0
    STEPS.each do |st|
      found += 1
      return found if st[:title] == title
    end
    nil
  end

  def link_to_next_step(step_number)
    STEPS[step_number][:path]
  end

  def add_setup_breadcrumb
    add_breadcrumb 'Setup', setup_start_index_path
    add_breadcrumb 'Create new course' if controller_name.starts_with?('course_')
  end

  def print_setup_phases(phase = 0)
    STEPS.each_with_index do |st, i|
      path = nil
      if i < phase - 1
        type = 'visited'
        path = STEPS[i][:path]
      elsif i == phase - 1
        type = 'current'
      else
        type = 'unavailable'
      end
      add_phase (i+1).to_s+'. '+STEPS[i][:title], type, path
    end
  end

  def add_phase(name, type, url = '')
    @course_setup_phases ||= []
    url = eval(url.to_s) if url =~ /_path|_url|@/
    @course_setup_phases << { name: name, url: url, type: type }
  end

  private

  def set_organization
    @organization = Organization.find_by(slug: params[:organization_id])
  end

  def set_course
    @course = Course.find(params[:course_id]) unless params[:course_id].nil?
  end
end
