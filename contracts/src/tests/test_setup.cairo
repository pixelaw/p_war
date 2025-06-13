#[cfg(test)]
mod tests {
    use pixelaw_testing::helpers::{setup_core};
    use pwar::tests::utils::{deploy_pwar};

    #[test]
    #[available_gas(300000000)]
    fn test_setup() {
        //compare scarb.toml and all the other tomls with app template.
        let (mut world, _core_actions, _player_1, _player_2) = setup_core();
        println!("core setup done!");
        let (_pwar_actions, _propose, _voting, _guild) = deploy_pwar(ref world);
    }
}

