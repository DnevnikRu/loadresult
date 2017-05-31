class PerformanceLabelsController < ApplicationController
  before_action :set_label, only: [:edit, :update, :destroy]

  def new
  end

  def destroy
    @label.destroy
    redirect_to(:back, notice: 'Label was successfully destroyed.')
  end

  def create
    label = PerformanceLabel.create_new_label(params)
    if label.errors.empty?
      redirect_to(performance_group_url, notice: 'Label was successfully created.')
    else
      flash.now[:label] = params[:label]
      flash[:alert] = label.errors.full_messages
      redirect_to :back
    end
  end

  def edit
    flash.now[:label] = @label[:label]
  end

  def update
    label = PerformanceLabel.edit_label(@label, params)
    if label.errors.empty?
      redirect_to(performance_group_performance_labels_path, notice: 'Label was successfully updated.')
    else
      flash.now[:label] = params[:label]
      flash.now[:alert] = group.errors.full_messages
      render action: :edit
    end
  end

  def set_label
    @label = PerformanceLabel.find_by(id: params[:id])
  end

end
