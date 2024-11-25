use pixelaw::core::utils::DefaultParameters;

#[starknet::interface]
trait IAllowedApp {
    fn set_pixel(default_params: DefaultParameters);
}
