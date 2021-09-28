class CheckoutsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create_subscription, :update_subscription, :music_payment_session]
  before_action :authenticate_user!
  layout "user_layout"
  
  ##--
  # Purpose: create subscription for chat and post and tv daily program
  ##++
  def create_subscription
    begin
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      stripe_customer = Stripe::Customer.create({email: current_user.email,
        description: "added user_subscrition",
        name: current_user.first_name+" "+ current_user.last_name,
        phone: current_user.phone_number,
        source: params[:stripe_card_token]
      })
      if stripe_customer.nil?
        flash[:error] = "Invalid card details"
        render json: {status: 500}
      else
        plan = UserPlan.find_by_plan_id_stripe(params[:plan])
        subscription = Stripe::Subscription.create({
          customer:  stripe_customer.id,
          items: [
            {price: plan.plan_id_stripe},
          ],
          trial_period_days: plan.free_trial ? (plan.trial_interval == "week" ? 7*plan.trial_interval_count.to_i : 1*plan.trial_interval_count.to_i) : null,
        })
        if subscription.present? && (subscription.status == "trialing" || subscription.status == "active")
          user_subscription = current_user.user_subscriptions.new(active_status: true, transaction_id: subscription.id,plan_type: subscription.items.data[0][:plan].id,subscription_amount: subscription.items.data[0][:plan].amount.to_f/100,user_plan_id: plan.id,effective_from: Time.at(subscription.current_period_start),effective_to: Time.at(subscription.current_period_end), stripe_customer_id: stripe_customer.id, trial_from: (subscription.trial_start.present? ? Time.at(subscription.trial_start) : nil), trial_to: (subscription.trial_end.present? ? Time.at(subscription.trial_end) : nil), plan_status: subscription.status)
          if user_subscription.save
            flash[:success] = "User #{subscription.status == "trialing" ? 'free trial' : 'subscription'} created successfully"
            render json: {status: 200}
          else
            redirect_to checkout_payment_path
          end
        end
      end
    rescue Exception => e
      puts e
      flash[:success] = "Something went wrong, Please check your card details and try again."
      render json: {status: 401}
    end
  end

  ##--
  # Purpose: update/renew subscription for chat and post and tv daily program
  ##++
  def update_subscription
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    stripe_customer = Stripe::Customer.create({email: current_user.email,
      description: "added user_subscrition",
      name: current_user.first_name+" "+ current_user.last_name,
      phone: current_user.phone_number,
      source: params[:stripe_card_token]
    })
    if stripe_customer.nil?
      flash[:error] = "Invalid card details"
      render json: {status: 500}
    else
      begin 
        plan = UserPlan.find_by_plan_id_stripe(params[:plan])
        subscription = Stripe::Subscription.create({
          customer:  stripe_customer.id,
          items: [
            {price: plan.plan_id_stripe},
          ],})
        if subscription.present? && subscription.status == "active"
          previous_subscription = current_user.user_subscriptions
          previous_subscription.update_all(active_status: false) if previous_subscription.present?
          user_subscription = current_user.user_subscriptions.create(active_status: true, transaction_id: subscription.id,plan_type: subscription.items.data[0][:plan].id,subscription_amount: subscription.items.data[0][:plan].amount.to_f/100,user_plan_id: plan.id,effective_from: Time.at(subscription.current_period_start),effective_to: Time.at(subscription.current_period_end), stripe_customer_id: stripe_customer.id, plan_status: subscription.status)
          flash[:success] = "Subscription updated successfully."
          render json: {status: 200}
        end
      rescue Exception => e
        flash[:success] = "Something went wrong, Please check your card details and try again."
        render json: {status: 401}
      end
    end
  end

  ##--
  # Purpose: create payment session for music downloads
  ##++
  def music_payment_session
    if params[:music_id].present?
      begin
        Stripe.api_key = ENV['STRIPE_SECRET_KEY']
        music = Music.find(params[:music_id])
        stripe_session = Stripe::Checkout::Session.create({
          payment_method_types: ['card'],
          line_items: [{
            price_data: {
              currency: 'usd',
              product_data: {
                name: music.title.presence || 'Music Product',
              },
              unit_amount: (music.price*100).to_i,
            },
            quantity: 1,
          }],
          mode: 'payment',
          success_url: "#{request.base_url}/success_music_payment?music_id=#{params[:music_id]}&album_id=#{params[:album_id]}",
          cancel_url: "#{request.base_url}/get_songs_by_album?id=#{params[:album_id]}",
        })
        session[:stripe_session_id] = stripe_session.id if stripe_session.present?
        render json: {status: 200, session_url: stripe_session.url}
      rescue Exception => e
        puts e
        flash[:success] = "Something went wrong, Please check your card details and try again."
        render json: {status: 401}
      end
    else
      flash[:success] = "Something went wrong."
      render json: {status: 401}
    end
  end

  ##--
  # Purpose: create payment for music downloads when stripe payment successful
  ##++
  def success_music_payment
    if params[:music_id].present? && session[:stripe_session_id].present?
      stripe_session = Stripe::Checkout::Session.retrieve(session[:stripe_session_id])
      if stripe_session.present?
        music_payment = MusicPayment.create(amount: stripe_session.amount_total/100, transaction_id: stripe_session.payment_intent, user_id: current_user.id, music_id: params[:music_id])
        redirect_to get_songs_by_album_path(id: params[:album_id]), :notice => "Music Payment is done successfully. You can now download it directly!" if music_payment.save
      end
    end
  end

  private
  def users_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :term_and_condition, :password, :user_name)
  end
end