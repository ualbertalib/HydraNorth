class Ability
  include Hydra::Ability
  include Sufia::Ability

  def custom_permissions 
    can :manage, :all if user_groups.include? 'admin'
  end
  
end
