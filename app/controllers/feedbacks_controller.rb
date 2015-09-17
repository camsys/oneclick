class FeedbacksController < ApplicationController
  before_filter :set_feedback, only: [:edit, :update]
  
  def new
    @feedback = Feedback.new
    respond_to do |format|
      format.js { render partial: 'feedbacks/stripped_form' }
    end
  end

  def create
    feedback_type_id = params[:feedback][:feedback_type_id]
    trip_id = params[:feedback][:trip_id]
    existing_feedback = Feedback.where(feedback_type_id: feedback_type_id, trip_id: trip_id)

    if trip_id && !existing_feedback.empty?
      respond_to do |format|
        existing_feedback.each do |feedback|
          @feedback = feedback
          if params[:feedback].each { |k,v| k.include?("id") ? @feedback.update_attribute(k, v.to_i) : @feedback.update_attribute(k, v) }
            params[:feedback_ratings_feedbacks].each do |k,v|
              rating_to_update = FeedbackRatingsFeedback.where(feedback: @feedback, feedback_rating: FeedbackRating.find_by(name: k)).first_or_create
              rating_to_update.update_attribute('value', v[:value].to_i)
            end
            params[:feedback_issues_feedbacks].each do |k,v|
              issue_to_update = FeedbackIssuesFeedback.where(feedback: @feedback, feedback_issue: FeedbackIssue.find_by(name: k)).first_or_create
              issue_to_update.update_attribute('value', v[:value].to_i)
            end            
            ratings = @feedback.ratings.map { |f| f.value }.reject { |f| [-1,nil,''].include?(f) }
            avg = ratings.empty? ? 0 : (ratings.reduce(:+) / ratings.count)
            @feedback.update_attribute('average_rating', avg)

            format.json { render json: @feedback }
          else
            format.json { render json: @feedback.errors, status: :unprocessable_entity }
          end
        end
      end

    else

      @feedback = Feedback.new(feedback_params)
      respond_to do |format|
        @feedback.update_attribute("feedback_type_id", feedback_type_id.to_i)
        if @feedback.save
          params[:feedback_ratings_feedbacks].each do |k,v|
            @feedback.feedback_ratings_feedbacks << FeedbackRatingsFeedback.create(feedback: @feedback, feedback_rating: FeedbackRating.find_by(name: k), value: v[:value].to_i)
          end
          params[:feedback_issues_feedbacks].each do |k,v|
            @feedback.feedback_issues_feedbacks << FeedbackIssuesFeedback.create(feedback: @feedback, feedback_issue: FeedbackIssue.find_by(name: k), value: v[:value].to_i)
          end
          ratings = @feedback.ratings.map { |f| f.value }.reject { |f| [-1,nil,''].include?(f) }
          avg = ratings.empty? ? 0 : (ratings.reduce(:+) / ratings.count)
          @feedback.update_attribute('average_rating', avg)

          format.json { render json: @feedback }
        else
          format.json { render json: @feedback.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  def edit
  end

  def update
  end

  def get_ratings_and_issues
    @feedback_type = FeedbackType.find(params[:feedback_type])
    @ratings = FeedbackRatingsFeedbackType.where(feedback_type: @feedback_type)
    @issues = FeedbackIssuesFeedbackType.where(feedback_type: @feedback_type)
  end

  private

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def feedback_params
    params.require(:feedback).permit(:id, :user_id, :user_email, :feedback_type_id, :feedback_rating_id, :feedback_issue_id, :feedback_status_id, :comment, :trip_id, :average_rating)
  end
end
