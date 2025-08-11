class MembershipToggleService
  def initialize(user)
    @user = user
  end

  def call
    current_membership = @user.membership_type
    
    case current_membership
    when 'none'
      upgrade_to_monthly
    when 'monthly'
      upgrade_to_unlimited
    when 'unlimited'
      cancel_membership
    else
      set_default_membership
    end
  end

  private

  def upgrade_to_monthly
    @user.update!(membership_type: 'monthly', membership_discount: 5.0)
    { message: "#{@user.full_name} now has a monthly membership with 5% discount." }
  end

  def upgrade_to_unlimited
    @user.update!(membership_type: 'unlimited', membership_discount: 15.0)
    { message: "#{@user.full_name} upgraded to unlimited membership with 15% discount." }
  end

  def cancel_membership
    @user.update!(membership_type: 'none', membership_discount: 0)
    { message: "#{@user.full_name}'s membership has been cancelled." }
  end

  def set_default_membership
    @user.update!(membership_type: 'monthly', membership_discount: 5.0)
    { message: "#{@user.full_name} now has a monthly membership." }
  end
end
