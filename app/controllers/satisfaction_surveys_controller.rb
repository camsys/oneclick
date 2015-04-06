class SatisfactionSurveysController < ApplicationController
 
  def index
  end

  def new
    @satisfaction_survey = SatisfactionSurvey.new
  end

  def edit
    @satisfaction_survey = SatisfactionSurvey.find(params[:id])
  end

  def create
    @satisfaction_survey = SatisfactionSurvey.new(satisfaction_survey_params)
    if @satisfaction_survey.save
      flash[:notice] = "Survey submited."
      redirect_to :back
    else
      flash[:notice] = "Saving survey failed."
      redirect_to :back
    end
  end

  def update
    if @satisfaction_survey.update(satisfaction_survey_params)
      redirect_to :back
      flash[:notice] = "Survey updated."
    else
      redirect_to :back
      flash[:alert] = "There was a problem saving."
    end
  end

  private

  def satisfaction_survey_params
    params.require(:satisfaction_survey).permit(:trip_id, :satisfied, :comment)
  end

end
