class BusinessPartnersController < ApplicationController
  include CustomHelper
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /BusinessPartners
  # GET /BusinessPartners.json

  def index
    super
  end

  def model
    BusinessPartner
  end

  # GET /BusinessPartners/1
  # GET /BusinessPartners/1.json
  def show
  end

  # GET /BusinessPartners/new
  def new
    @business_partner = BusinessPartner.new
  end

  # GET /BusinessPartners/1/edit
  def edit
  end

  # POST /BusinessPartners
  # POST /BusinessPartners.json
  def create
    @business_partner = BusinessPartner.new(client_params)
  
    respond_to do |format|
      if @business_partner.save
        format.html { redirect_to @business_partner, notice: t('views.business_partners.controller_msjs.created') }
        format.json { render action: 'show', status: :created, location: @business_partner }
      else
        format.html { render action: 'new' }
        format.json { render json: @business_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /BusinessPartners/1
  # PATCH/PUT /BusinessPartners/1.json
  def update
    respond_to do |format|
      if @business_partner.update(client_params)
        format.html { redirect_to @business_partner, notice: t('views.business_partners.controller_msjs.updated') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @business_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /BusinessPartners/1
  # DELETE /BusinessPartners/1.json
  def destroy
    @business_partner.destroy
    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @business_partner = BusinessPartner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:business_partner).permit(:sap_code, :company_name, :alias, :commercial_contact_name,
                                               :commercial_contact_email, :production_contact_name,
                                               :production_contact_email, :address_one, :address_two, :address_three,
                                               :location_one, :location_two, :location_three, :remarks, :country,
                                               :status, :status_comment, :phone)
    end
end
