class TestResultsController < ApplicationController
  before_filter :authorize
  def new
    @test_result = current_user.test_results.build
    
    TestPart.all.each do |tp|
      tp.test_questions.each do |q|
        @test_result.test_answers.build :test_question_id=>q.id
      end
    end
  end
  
  def create
    @test_result = current_user.test_results.build params[:test_result]
    if @test_result.save
      types = {}
      @test_result.test_answers.each do |a|
        if a.test_question.test_part.gebruik_voor_match? and a.answer.to_s == 'true'
          if types.keys.include?(a.test_question.mens_type)
            types[a.test_question.mens_type] = types[a.test_question.mens_type] + 1 
          else
            types[a.test_question.mens_type] = 1
          end
        end
      end
      highest = types.values.sort.last
      mens_type = types.key(highest)
      if mens_type
        test_result_type = TestResultType.find_by_mens_type(mens_type)
        @test_result.update_attribute(:test_result_type_id, test_result_type.id) if test_result_type.present?
      end
      redirect_to result_test_results_path
    else
      render :new
    end
  end
  
  def result
    @test_result = current_user.test_results.last
    redirect_to new_test_result_path and return if @test_result.blank?

    types_match = {}
    types = {}
    @test_result.test_answers.each do |a|
      if !a.test_question.test_part.gebruik_voor_match? and a.answer.to_s == 'true'
        if types.keys.include?(a.test_question.mens_type)
          types[a.test_question.mens_type] = types[a.test_question.mens_type] + 1 
        else
          types[a.test_question.mens_type] = 1
        end
      end
      if a.test_question.test_part.gebruik_voor_match? and a.answer.to_s == 'true'
        if types_match.keys.include?(a.test_question.mens_type)
          types_match[a.test_question.mens_type] = types_match[a.test_question.mens_type] + 1 
        else
          types_match[a.test_question.mens_type] = 1
        end
      end
    end
    @mens_types_match = types_match.sort {|a,b| a[1]<=>b[1]}.reverse
    @mens_types_match.shift 
    highest = types.values.sort.last
    @mens_type = types.key(highest)
    if @mens_type
      @extra_part = TestPart.where(:gebruik_voor_match=>false).first
      @test_result_type = TestResultType.find_by_mens_type(@mens_type)
    end
  end
end
