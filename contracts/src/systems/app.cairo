use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use pixelaw::core::utils::DefaultParameters;
use starknet::ContractAddress;

#[starknet::interface]
trait IAllowedApp<TContractState> {
    fn set_pixel(ref self: TContractState, default_params: DefaultParameters);
}

#[dojo::contract(namespace: "pixelaw", nomapping: true)]
mod allowed_app_actions {
    use super::IAllowedApp;
    use pixelaw::core::utils::DefaultParameters;
    
    #[abi(embed_v0)]
    impl AllowedAppImpl of IAllowedApp<ContractState> {
        fn set_pixel(ref self: ContractState, default_params: DefaultParameters) {
            // Implementation here
        }
    }
}