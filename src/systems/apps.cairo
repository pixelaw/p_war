use pixelaw::core::utils::DefaultParameters;

#[dojo::interface]
trait IAllowedApp {
    fn set_pixel(default_params: DefaultParameters);
}
