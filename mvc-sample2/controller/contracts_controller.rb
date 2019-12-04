class ContractsController < ApplicationController
  load_and_authorize_resource
  before_action :channel_partner
  before_action :contract, only: [:show, :destroy, :update, :restore, :edit, :to_pdf, :complete, :a_new_agreement_contract_path]
  before_action :contracts, only: [:index, :destroy, :restore, :a_new_agreement_contract_path]
  before_action :deleted_contract, only: [:index, :destroy, :restore]
  before_action :incomplete_contracts, only: [:index, :destroy, :restore]
  before_action :clauses, only: [:new, :edit, :create, :update], if: :redirect_clauses_params
  before_action :definitions, only: [:new, :edit, :create, :update], if: :redirect_definitions_params
  before_action :parties, only: [:new, :edit, :create, :update], if: :redirect_parties_params
  before_action :free_texts, only: [:new, :edit, :create, :update], if: :redirect_free_text_params
  before_action :is_complete?, only: [:edit, :update]

  layout :false, only: [:to_pdf]
  def index
  end



  def new
    @contract = Contract.new
  end

  def create
    @contract = Contract.new(contract_params)
    @contract.channel_partner_id = channel_partner.id 
    if @contract.save
      flash.now[:alert] = 'Contract saved successfuly!'
      if (params[:status] == 'continue')
        render :edit
      else
        render :show
      end
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @contract.update(contract_params)
      flash.now[:alert] = 'Contract saved successfuly!'
      if (params[:status] == 'continue')
        #render :edit
        redirect_to edit_contract_path(@contract)
      else
        #render :show
        redirect_to contract_path(@contract)
        
      end
    else
      flash.now[:alert] = 'Contract update failed!'
      render :show
    end
  end

  def to_pdf
    render pdf: @contract.title&.parameterize, formats: :html, encoding: 'utf8', page_size: 'A4', font_name: 'sans-serif' #, show_as_html: true
  end

  def destroy
    if @contract.deleted?
      @contract.destroy
      flash.now[:alert] = "Contract deleted successfuly!"
    else
      @contract.delete
      flash.now[:alert] = "Contract deleted successfuly!"
    end
    render :index
  end

  def restore
    if @contract.deleted?
      @contract.restore
      flash.now[:alert] = "Contract restore successfuly!"
    end
    render :index
  end

  def search_repository
    query = generate_query(params[:search])
    case params[:section_type]
    when 'clauses'
      @section_roots = Section.where(query).active&.ordered_by_sequence&.roots.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
      @partial = 'sections'
    when 'parties'
      @parties = Party.where(query).active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
      @partial = 'parties'
    when 'definitions'
      @definitions = Definition.where(query).active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
      @partial = 'definitions'
    when 'free_text'
      @contract_free_texts = ContractFreeText.where(query).active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
      @partial = 'contract_free_texts'
    end
  end

  def clone
    cc = Contract.find_by(id: params[:contract_id])
    @contract = Contract.new(title: cc.title, sub_title: cc.sub_title,  body: cc.body )
  end

  def complete
    if @contract.update(complete: true)
      flash.now[:alert] = 'Contract save as completed!'
    else
      flash.now[:alert] = 'Contract not save as complete!'
    end
    render :show
  end

  private
  
  def contract_params
    params.require(:contract).permit(:name, :title, :sub_title, :body)
  end

  def channel_partner
    @channel_partner = current_user.channel_partner
  end

  def contract
    # @contract = @channel_partner.contracts.find_by(id: params[:id])
  
  end

  def contracts
    @contracts = @channel_partner.contracts.active
  end

  def deleted_contract
    @deleted_contract = @channel_partner.contracts.deleted
  end

  def incomplete_contracts
    @incomplete_contracts = @channel_partner.contracts.active.incomplete
  end

  def clauses
    @section_roots = @channel_partner.sections.active&.ordered_by_sequence&.roots.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
  end
  
  def definitions
    @definitions = @channel_partner.definitions.active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
  end
  
  def parties
    @parties = @channel_partner.parties.active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
  end
  
  def free_texts
    @contract_free_texts = @channel_partner.contract_free_texts.active.paginate(:page => params[:page], :per_page => ContractText::PER_PAGE)
  end

  def redirect_clauses_params
    params[:r] == 'clauses'
  end

  def redirect_definitions_params
    params[:r] == 'definitions'
  end
  
  def redirect_parties_params
    params[:r] == 'parties'
  end
  
  def redirect_free_text_params
    params[:r] == 'free_text'
  end

  def generate_query(search)
    qry_separator =  search.split(' ')
    query = ''
    query = "similarity(content, '#{search}')>0.1"
    # qry_separator.each do |qury_s|
    #   query += "lower(content) ILIKE '%#{qury_s.strip}%' #{'OR' unless qury_s==qry_separator.last} "
    # end
    query
  end

  def is_complete?
    if contract.complete
      flash[:alert] = 'Contract cannot be edited!'
      redirect_to root_url
    end
  end
end