#[cfg(test)]
mod tests {
    // use dojo::world::{ModelStorage};
    use pwar::tests::utils::{deploy_pwar};
    use pixelaw_testing::helpers::{setup_core};

    #[test]
    #[available_gas(300000000)]
    fn test_setup() {
        //compare scarb.toml and all the other tomls with app template.
        let (mut world, _core_actions, _player_1, _player_2) = setup_core();
        println!("core setup done!");
        let (_world, _pwar_actions, _propose, _voting, _guild) = deploy_pwar(ref world);
    }
}

