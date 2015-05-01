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
    @satisfaction_survey.reasoning = params[:satisfaction_survey][:reasoning]
    respond_to do |format|
      if @satisfaction_survey.save
        format.json { render json: @satisfaction_survey }
      else
        format.json { render json: @satisfaction_survey.errors, status: :unprocessable_entity }
        format.html { redirect_to :back, notice: t(:saving_survey_failed) }
      end
    end
  end

  def update
    if @satisfaction_survey.update(satisfaction_survey_params)
      redirect_to :back
      flash[:notice] = t(:survey_updated)
    else
      redirect_to :back
      flash[:alert] = t(:problem_saving)
    end
  end

  private

  def satisfaction_survey_params
    params.require(:satisfaction_survey).permit(:trip_id, :satisfied, :reasoning, :comment)
  end

end
