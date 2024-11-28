use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use pixelaw::core::utils::DefaultParameters;
use pixelaw::core::models::pixel::PixelUpdate;
use starknet::{ContractAddress, get_contract_address};
use super::actions::{IActionsDispatcher, IActionsDispatcherTrait};  // Add this import

#[starknet::interface]
trait IAllowedApp<TContractState> {
    fn set_pixel(ref self: TContractState, default_params: DefaultParameters);
}

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod allowed_app_actions {
    use super::IAllowedApp;
    use pixelaw::core::utils::DefaultParameters;
    use pixelaw::core::models::pixel::PixelUpdate;
    use starknet::{ContractAddress, get_contract_address};
    use super::super::actions::{IActionsDispatcher, IActionsDispatcherTrait};  // Add this import
    
    #[abi(embed_v0)]
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(ref self: ContractState, default_params: DefaultParameters) {
            let actions = IActionsDispatcher { contract_address: get_contract_address() };
            actions
                .update_pixel(
                    PixelUpdate {
                        x: default_params.position.x,
                        y: default_params.position.y,
                        color: Option::Some(default_params.color),
                        timestamp: Option::None,
                        text: Option::None,
                        app: Option::None,
                        owner: Option::None,
                        action: Option::None
                    }
                );
        }
    }
}