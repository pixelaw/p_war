#[cfg(test)]
mod tests {
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo::world::{ModelStorage};
    use p_war::tests::utils::{deploy_p_war};
    use pixelaw_testing::helpers::{setup_core_initialized};

    #[test]
    #[available_gas(100000)]
    fn test_setup() {
        let (mut world, _core_actions, _player_1, _player_2) = setup_core_initialized();
        let (_world, _p_war_actions, _propose, _voting, _guild, _allowed_app) = deploy_p_war(ref world);
    }
}

