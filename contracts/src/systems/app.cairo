use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use pixelaw::core::utils::DefaultParameters;
use pixelaw::core::models::pixel::PixelUpdate;
use starknet::{ContractAddress, get_contract_address};
use super::actions::{IActionsDispatcher, IActionsDispatcherTrait};  // Add this import

#[starknet::interface]
trait IAllowedApp<TContractState> {
    fn set_pixel(ref self: TContractState, default_params: DefaultParameters);
}

// ... existing code ...

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod allowed_app_actions {
    use super::IAllowedApp;
    use pixelaw::core::utils::DefaultParameters;
    use pixelaw::core::models::pixel::PixelUpdate;
    use starknet::{ContractAddress, get_contract_address};
    use pixelaw::core::actions::{
        IActionsDispatcher as ICoreActionsDispatcher,
        IActionsDispatcherTrait as ICoreActionsDispatcherTrait
    };
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use pixelaw::core::utils::get_core_actions;
    
    #[abi(embed_v0)]
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(ref self: ContractState, default_params: DefaultParameters) {
            // Instead of calling back to actions, call core_actions directly
            let mut world = self.world(@"pixelaw");
            let core_actions = get_core_actions(ref world);
            let player = starknet::get_tx_info().unbox().account_contract_address;
            let system = get_contract_address();

            core_actions.update_pixel(
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
                false
            );
        }
    }
}