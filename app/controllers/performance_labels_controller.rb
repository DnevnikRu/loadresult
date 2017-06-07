class PerformanceLabelsController < ApplicationController
  before_action :set_label, only: [:edit, :update, :destroy]
  before_action :set_group, only: [:index]

  def index
    @labels = PerformanceLabel.where(performance_group_id: params['performance_group_id']).order('id ASC')
  end

  def create
    label = PerformanceLabel.create_new_label(params)
    if label.errors.empty?
      redirect_to(performance_group_performance_labels_url, notice: 'Performance label was successfully created.')
    else
      flash.now[:label] = params[:label]
      flash[:alert] = label.errors.full_messages
      redirect_to :back
    end
  end

  def update
    label = PerformanceLabel.edit_label(@label, params)
    if label.errors.empty?
      redirect_to(performance_group_performance_labels_url, notice: 'Performance label was successfully updated.')
    else
      flash.now[:label] = params[:label]
      flash.now[:alert] = label.errors.full_messages
      render action: :edit
    end
  end

  def edit
    flash.now[:label] = @label[:label]
  end

  def destroy
    @label.destroy
    redirect_to(performance_group_performance_labels_url, notice: 'Performance label was successfully deleted.')
  end

  def set_group
    @group = PerformanceGroup.find_by(id: params[:performance_group_id])
  end

  private

  def set_label
    @label = PerformanceLabel.find_by(id: params[:id])
  end


end
