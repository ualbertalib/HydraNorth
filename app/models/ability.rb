class Ability
  include Hydra::Ability
  include Sufia::Ability

  def custom_permissions 
    cannot :destroy, ::GenericFile unless user_groups.include? 'admin'
    can :manage, :all if user_groups.include? 'admin'
  end
  
end
