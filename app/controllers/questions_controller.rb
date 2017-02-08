class QuestionsController < ApplicationController
  before_action :set_question, only: [:home, :show, :edit, :update, :destroy]

  def index
    @questions = Question::Question.all
  end

  def create
    # Blank action for initial creation of a question
  end
  
  def build
    # Blank action for initial building of a question
  end

  def show
    # Show question
  end

  def update
    if params['/questions/create'].nil?
      redirect_to questions_path and return
    end
    
    # Grab the params and whitelist them given the type
    question_params = params['/questions/create'].to_unsafe_h
    type = question_params[:question_type]
    question_params = filter_params_for_type(question_params, type)

    # Create the correct type of question
    if type == 'Text'
      @question_type = Question::StringQuestion.new
    elsif type == 'True or False' 
      @question_type = Question::BooleanQuestion.new
    elsif type == 'Multiple Choice'
      @question_type = Question::MultipleChoiceQuestion.new
    elsif type == 'Date and Time'
      @question_type = Question::DateTimeQuestion.new
    end

    # Save and update
    if @question_type && (!question_params.nil? && !question_params.empty?)
      @question_type.save!
      @question_type.update(question_params)
    end

    redirect_to questions_path
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_question
      @question = Question::Question.find(params[:id]) rescue nil
    end

    def question_params
      params.permit! # TODO
    end
    
    def filter_params_for_type(params, type)
      if ['Text', 'True or False', 'Date and Time'].include? type
        wanted = ['question', 'required', 'step', 'question_type']
        return params.select { |key, _| wanted.include? key }
      elsif ['Multiple Choice'].include? type
        wanted = ['question', 'required', 'step', 'question_type', 'multi_options']
        return params.select { |key, _| wanted.include? key }
      end
    end
end
