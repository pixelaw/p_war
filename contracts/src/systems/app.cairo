use pixelaw::core::utils::DefaultParameters;

#[starknet::interface]
pub trait IAllowedApp<TContractState> {
    fn set_pixel(ref self: TContractState, default_params: DefaultParameters);
}

#[dojo::contract]
mod allowed_app_actions {
    use pixelaw::core::actions::{
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use pixelaw::core::models::pixel::PixelUpdate;
    use pixelaw::core::utils::{DefaultParameters, get_core_actions};
    use starknet::get_contract_address;
    use super::IAllowedApp;

    #[abi(embed_v0)]
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(ref self: ContractState, default_params: DefaultParameters) {
            // Instead of calling back to actions, call core_actions directly
            let mut world = self.world(@"p_war");
            let core_actions = get_core_actions(ref world);
            let player = starknet::get_tx_info().unbox().account_contract_address;
            let system = get_contract_address();

            core_actions
                .update_pixel(
                    player,
                    system,
                    PixelUpdate {
                        x: default_params.position.x,
                        y: default_params.position.y,
                        color: Option::Some(default_params.color),
                        timestamp: Option::None,
                        text: Option::None,
                        app: Option::None,
                        owner: Option::None,
                        action: Option::None
                    },
                    Option::None,
                    true
                );
        }
    }
}
