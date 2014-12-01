require 'spec_helper'

describe FeedbackAnswersController, :type => :controller do
  before :each do
    @exercise = Factory.create(:exercise)
    @course = @exercise.course
    @user = Factory.create(:user)
    @submission = Factory.create(:submission, :course => @course, :exercise => @exercise, :user => @user)
    @q1 = Factory.create(:feedback_question, :kind => 'text', :course => @course)
    @q2 = Factory.create(:feedback_question, :kind => 'intrange[1..5]', :course => @course)

    controller.current_user = @submission.user
  end

  describe "#create" do
    before :each do
      @valid_params = {
        :submission_id => @submission.id,
        :answers => [
          { :question_id => @q1.id, :answer => 'foobar' },
          { :question_id => @q2.id, :answer => '3' }
        ],
        :format => :json,
        :api_version => ApiVersion::API_VERSION
      }
    end

    it "should accept answers to all questions associated to the submission's course at once" do
      post :create, @valid_params

      expect(response).to be_successful

      answers = FeedbackAnswer.order(:feedback_question_id)
      expect(answers.count).to eq(2)
      expect(answers[0].feedback_question_id).to eq(@q1.id)
      expect(answers[1].feedback_question_id).to eq(@q2.id)
      expect(answers[0].answer).to eq('foobar')
      expect(answers[1].answer).to eq('3')
    end

    it "should not save any answers and return withan error if even one answer is invalid" do
      params = @valid_params.clone
      params[:answers][1][:answer] = 'something invalid'

      post :create, params

      expect(response).not_to be_successful
      expect(FeedbackAnswer.all.count).to eq(0)
    end

    it "should not allow answering on behalf of another user" do
      another_user = Factory.create(:user)
      another_submission = Factory.create(:submission, :course => @course, :exercise => @exercise, :user => another_user)
      params = @valid_params.clone
      params[:submission_id] = another_submission.id

      expect { post :create, params }.to raise_error
    end
  end
end
