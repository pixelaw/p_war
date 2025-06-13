export const pwarManifest = [
    {
      "address": "0x38be037c76817f4d73f7cec04a5bffb9d64ce544674f72637563708971ef1d3",
      "class_hash": "0x3ee99e91fdfa35698d20960111322d90bba48f0429d2c00ce2656f0ce8eb21e",
      "abi": [
        {
          "type": "impl",
          "name": "guild_actions__ContractImpl",
          "interface_name": "dojo::contract::interface::IContract"
        },
        {
          "type": "interface",
          "name": "dojo::contract::interface::IContract",
          "items": []
        },
        {
          "type": "impl",
          "name": "guild_actions__DeployedContractImpl",
          "interface_name": "dojo::meta::interface::IDeployedResource"
        },
        {
          "type": "struct",
          "name": "core::byte_array::ByteArray",
          "members": [
            {
              "name": "data",
              "type": "core::array::Array::<core::bytes_31::bytes31>"
            },
            {
              "name": "pending_word",
              "type": "core::felt252"
            },
            {
              "name": "pending_word_len",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::meta::interface::IDeployedResource",
          "items": [
            {
              "type": "function",
              "name": "dojo_name",
              "inputs": [],
              "outputs": [
                {
                  "type": "core::byte_array::ByteArray"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "GuildImpl",
          "interface_name": "pwar::systems::guilds::IGuild"
        },
        {
          "type": "enum",
          "name": "core::bool",
          "variants": [
            {
              "name": "False",
              "type": "()"
            },
            {
              "name": "True",
              "type": "()"
            }
          ]
        },
        {
          "type": "struct",
          "name": "core::array::Span::<core::starknet::contract_address::ContractAddress>",
          "members": [
            {
              "name": "snapshot",
              "type": "@core::array::Array::<core::starknet::contract_address::ContractAddress>"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pwar::models::guilds::Guild",
          "members": [
            {
              "name": "game_id",
              "type": "core::integer::u32"
            },
            {
              "name": "guild_id",
              "type": "core::integer::u32"
            },
            {
              "name": "guild_name",
              "type": "core::felt252"
            },
            {
              "name": "creator",
              "type": "core::starknet::contract_address::ContractAddress"
            },
            {
              "name": "members",
              "type": "core::array::Span::<core::starknet::contract_address::ContractAddress>"
            },
            {
              "name": "member_count",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "pwar::systems::guilds::IGuild",
          "items": [
            {
              "type": "function",
              "name": "create_guild",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_name",
                  "type": "core::felt252"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "add_member",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "new_member",
                  "type": "core::starknet::contract_address::ContractAddress"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "join_guild",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "remove_member",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "member",
                  "type": "core::starknet::contract_address::ContractAddress"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "is_member",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "member",
                  "type": "core::starknet::contract_address::ContractAddress"
                }
              ],
              "outputs": [
                {
                  "type": "core::bool"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "get_guild",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [
                {
                  "type": "pwar::models::guilds::Guild"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "get_player_commit",
              "inputs": [
                {
                  "name": "player_address",
                  "type": "core::starknet::contract_address::ContractAddress"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "get_player_owns",
              "inputs": [
                {
                  "name": "player_address",
                  "type": "core::starknet::contract_address::ContractAddress"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "get_guild_points",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_id",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "function",
          "name": "dojo_init",
          "inputs": [],
          "outputs": [],
          "state_mutability": "view"
        },
        {
          "type": "impl",
          "name": "WorldProviderImpl",
          "interface_name": "dojo::contract::components::world_provider::IWorldProvider"
        },
        {
          "type": "struct",
          "name": "dojo::world::iworld::IWorldDispatcher",
          "members": [
            {
              "name": "contract_address",
              "type": "core::starknet::contract_address::ContractAddress"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::world_provider::IWorldProvider",
          "items": [
            {
              "type": "function",
              "name": "world_dispatcher",
              "inputs": [],
              "outputs": [
                {
                  "type": "dojo::world::iworld::IWorldDispatcher"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "UpgradeableImpl",
          "interface_name": "dojo::contract::components::upgradeable::IUpgradeable"
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::upgradeable::IUpgradeable",
          "items": [
            {
              "type": "function",
              "name": "upgrade",
              "inputs": [
                {
                  "name": "new_class_hash",
                  "type": "core::starknet::class_hash::ClassHash"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "constructor",
          "name": "constructor",
          "inputs": []
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
          "kind": "struct",
          "members": [
            {
              "name": "class_hash",
              "type": "core::starknet::class_hash::ClassHash",
              "kind": "data"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "Upgraded",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
              "kind": "nested"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::world_provider::world_provider_cpt::Event",
          "kind": "enum",
          "variants": []
        },
        {
          "type": "event",
          "name": "pwar::systems::guilds::guild_actions::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "UpgradeableEvent",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
              "kind": "nested"
            },
            {
              "name": "WorldProviderEvent",
              "type": "dojo::contract::components::world_provider::world_provider_cpt::Event",
              "kind": "nested"
            }
          ]
        }
      ],
      "init_calldata": [],
      "tag": "pwar-guild_actions",
      "selector": "0x3c3b77d165909386294773571272f51dcefab9d0aa99d69b70796f6501d6f42",
      "systems": [
        "create_guild",
        "add_member",
        "join_guild",
        "remove_member",
        "upgrade"
      ]
    },
    {
      "address": "0x4038ddb14b806e40242355883643c009451a6b15fc9aa402a1248dae25a5a49",
      "class_hash": "0x7dd3c84c52aebfc627247b8890e9c54321fb971128c085470acf5e7ecef9b9",
      "abi": [
        {
          "type": "impl",
          "name": "propose_actions__ContractImpl",
          "interface_name": "dojo::contract::interface::IContract"
        },
        {
          "type": "interface",
          "name": "dojo::contract::interface::IContract",
          "items": []
        },
        {
          "type": "impl",
          "name": "propose_actions__DeployedContractImpl",
          "interface_name": "dojo::meta::interface::IDeployedResource"
        },
        {
          "type": "struct",
          "name": "core::byte_array::ByteArray",
          "members": [
            {
              "name": "data",
              "type": "core::array::Array::<core::bytes_31::bytes31>"
            },
            {
              "name": "pending_word",
              "type": "core::felt252"
            },
            {
              "name": "pending_word_len",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::meta::interface::IDeployedResource",
          "items": [
            {
              "type": "function",
              "name": "dojo_name",
              "inputs": [],
              "outputs": [
                {
                  "type": "core::byte_array::ByteArray"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "ProposeImpl",
          "interface_name": "pwar::systems::propose::IPropose"
        },
        {
          "type": "struct",
          "name": "pixelaw::core::utils::Position",
          "members": [
            {
              "name": "x",
              "type": "core::integer::u16"
            },
            {
              "name": "y",
              "type": "core::integer::u16"
            }
          ]
        },
        {
          "type": "struct",
          "name": "core::array::Span::<pixelaw::core::utils::Position>",
          "members": [
            {
              "name": "snapshot",
              "type": "@core::array::Array::<pixelaw::core::utils::Position>"
            }
          ]
        },
        {
          "type": "struct",
          "name": "core::array::Span::<core::integer::u32>",
          "members": [
            {
              "name": "snapshot",
              "type": "@core::array::Array::<core::integer::u32>"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pwar::models::game::Game",
          "members": [
            {
              "name": "id",
              "type": "core::integer::u32"
            },
            {
              "name": "start",
              "type": "core::integer::u64"
            },
            {
              "name": "end",
              "type": "core::integer::u64"
            },
            {
              "name": "proposal_idx",
              "type": "core::integer::u32"
            },
            {
              "name": "coeff_own_pixels",
              "type": "core::integer::u32"
            },
            {
              "name": "coeff_commits",
              "type": "core::integer::u32"
            },
            {
              "name": "winner_config",
              "type": "core::integer::u32"
            },
            {
              "name": "winner",
              "type": "core::starknet::contract_address::ContractAddress"
            },
            {
              "name": "guild_ids",
              "type": "core::array::Span::<core::integer::u32>"
            },
            {
              "name": "guild_count",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "enum",
          "name": "core::bool",
          "variants": [
            {
              "name": "False",
              "type": "()"
            },
            {
              "name": "True",
              "type": "()"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pwar::models::proposal::Proposal",
          "members": [
            {
              "name": "game_id",
              "type": "core::integer::u32"
            },
            {
              "name": "index",
              "type": "core::integer::u32"
            },
            {
              "name": "author",
              "type": "core::starknet::contract_address::ContractAddress"
            },
            {
              "name": "proposal_type",
              "type": "core::integer::u8"
            },
            {
              "name": "target_args_1",
              "type": "core::integer::u32"
            },
            {
              "name": "target_args_2",
              "type": "core::integer::u32"
            },
            {
              "name": "start",
              "type": "core::integer::u64"
            },
            {
              "name": "end",
              "type": "core::integer::u64"
            },
            {
              "name": "yes_voting_power",
              "type": "core::integer::u32"
            },
            {
              "name": "no_voting_power",
              "type": "core::integer::u32"
            },
            {
              "name": "is_activated",
              "type": "core::bool"
            }
          ]
        },
        {
          "type": "interface",
          "name": "pwar::systems::propose::IPropose",
          "items": [
            {
              "type": "function",
              "name": "create_proposal",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "proposal_type",
                  "type": "core::integer::u8"
                },
                {
                  "name": "target_args_1",
                  "type": "core::integer::u32"
                },
                {
                  "name": "target_args_2",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "activate_proposal",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "index",
                  "type": "core::integer::u32"
                },
                {
                  "name": "clear_data",
                  "type": "core::array::Span::<pixelaw::core::utils::Position>"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "add_new_color",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "index",
                  "type": "core::integer::u32"
                },
                {
                  "name": "game",
                  "type": "pwar::models::game::Game"
                },
                {
                  "name": "proposal",
                  "type": "pwar::models::proposal::Proposal"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "reset_to_white",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "index",
                  "type": "core::integer::u32"
                },
                {
                  "name": "game",
                  "type": "pwar::models::game::Game"
                },
                {
                  "name": "proposal",
                  "type": "pwar::models::proposal::Proposal"
                },
                {
                  "name": "clear_data",
                  "type": "core::array::Span::<pixelaw::core::utils::Position>"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "function",
          "name": "dojo_init",
          "inputs": [],
          "outputs": [],
          "state_mutability": "view"
        },
        {
          "type": "impl",
          "name": "WorldProviderImpl",
          "interface_name": "dojo::contract::components::world_provider::IWorldProvider"
        },
        {
          "type": "struct",
          "name": "dojo::world::iworld::IWorldDispatcher",
          "members": [
            {
              "name": "contract_address",
              "type": "core::starknet::contract_address::ContractAddress"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::world_provider::IWorldProvider",
          "items": [
            {
              "type": "function",
              "name": "world_dispatcher",
              "inputs": [],
              "outputs": [
                {
                  "type": "dojo::world::iworld::IWorldDispatcher"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "UpgradeableImpl",
          "interface_name": "dojo::contract::components::upgradeable::IUpgradeable"
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::upgradeable::IUpgradeable",
          "items": [
            {
              "type": "function",
              "name": "upgrade",
              "inputs": [
                {
                  "name": "new_class_hash",
                  "type": "core::starknet::class_hash::ClassHash"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "constructor",
          "name": "constructor",
          "inputs": []
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
          "kind": "struct",
          "members": [
            {
              "name": "class_hash",
              "type": "core::starknet::class_hash::ClassHash",
              "kind": "data"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "Upgraded",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
              "kind": "nested"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::world_provider::world_provider_cpt::Event",
          "kind": "enum",
          "variants": []
        },
        {
          "type": "event",
          "name": "pwar::systems::propose::propose_actions::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "UpgradeableEvent",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
              "kind": "nested"
            },
            {
              "name": "WorldProviderEvent",
              "type": "dojo::contract::components::world_provider::world_provider_cpt::Event",
              "kind": "nested"
            }
          ]
        }
      ],
      "init_calldata": [],
      "tag": "pwar-propose_actions",
      "selector": "0x5052f70e59d3197eee09586db5f0c9578581601c549020f478ffe96e57d8573",
      "systems": [
        "create_proposal",
        "activate_proposal",
        "add_new_color",
        "reset_to_white",
        "upgrade"
      ]
    },
    {
      "address": "0x2226c41273351a3d09127412d87eab7ee2c934b6978da1342229201966014fa",
      "class_hash": "0x273a59bed6da71650a30d4ff22b0c88329714d296a183b0171b14f36f72b9d3",
      "abi": [
        {
          "type": "impl",
          "name": "pwar_actions__ContractImpl",
          "interface_name": "dojo::contract::interface::IContract"
        },
        {
          "type": "interface",
          "name": "dojo::contract::interface::IContract",
          "items": []
        },
        {
          "type": "impl",
          "name": "pwar_actions__DeployedContractImpl",
          "interface_name": "dojo::meta::interface::IDeployedResource"
        },
        {
          "type": "struct",
          "name": "core::byte_array::ByteArray",
          "members": [
            {
              "name": "data",
              "type": "core::array::Array::<core::bytes_31::bytes31>"
            },
            {
              "name": "pending_word",
              "type": "core::felt252"
            },
            {
              "name": "pending_word_len",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::meta::interface::IDeployedResource",
          "items": [
            {
              "type": "function",
              "name": "dojo_name",
              "inputs": [],
              "outputs": [
                {
                  "type": "core::byte_array::ByteArray"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "function",
          "name": "dojo_init",
          "inputs": [],
          "outputs": [],
          "state_mutability": "external"
        },
        {
          "type": "impl",
          "name": "ActionsImpl",
          "interface_name": "pwar::systems::actions::IActions"
        },
        {
          "type": "enum",
          "name": "core::option::Option::<core::starknet::contract_address::ContractAddress>",
          "variants": [
            {
              "name": "Some",
              "type": "core::starknet::contract_address::ContractAddress"
            },
            {
              "name": "None",
              "type": "()"
            }
          ]
        },
        {
          "type": "enum",
          "name": "core::option::Option::<core::integer::u64>",
          "variants": [
            {
              "name": "Some",
              "type": "core::integer::u64"
            },
            {
              "name": "None",
              "type": "()"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pixelaw::core::utils::Position",
          "members": [
            {
              "name": "x",
              "type": "core::integer::u16"
            },
            {
              "name": "y",
              "type": "core::integer::u16"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pixelaw::core::utils::DefaultParameters",
          "members": [
            {
              "name": "player_override",
              "type": "core::option::Option::<core::starknet::contract_address::ContractAddress>"
            },
            {
              "name": "system_override",
              "type": "core::option::Option::<core::starknet::contract_address::ContractAddress>"
            },
            {
              "name": "area_hint",
              "type": "core::option::Option::<core::integer::u64>"
            },
            {
              "name": "position",
              "type": "pixelaw::core::utils::Position"
            },
            {
              "name": "color",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pwar::systems::guilds::IGuildDispatcher",
          "members": [
            {
              "name": "contract_address",
              "type": "core::starknet::contract_address::ContractAddress"
            }
          ]
        },
        {
          "type": "struct",
          "name": "core::array::Span::<core::integer::u32>",
          "members": [
            {
              "name": "snapshot",
              "type": "@core::array::Array::<core::integer::u32>"
            }
          ]
        },
        {
          "type": "struct",
          "name": "pwar::models::game::Game",
          "members": [
            {
              "name": "id",
              "type": "core::integer::u32"
            },
            {
              "name": "start",
              "type": "core::integer::u64"
            },
            {
              "name": "end",
              "type": "core::integer::u64"
            },
            {
              "name": "proposal_idx",
              "type": "core::integer::u32"
            },
            {
              "name": "coeff_own_pixels",
              "type": "core::integer::u32"
            },
            {
              "name": "coeff_commits",
              "type": "core::integer::u32"
            },
            {
              "name": "winner_config",
              "type": "core::integer::u32"
            },
            {
              "name": "winner",
              "type": "core::starknet::contract_address::ContractAddress"
            },
            {
              "name": "guild_ids",
              "type": "core::array::Span::<core::integer::u32>"
            },
            {
              "name": "guild_count",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "pwar::systems::actions::IActions",
          "items": [
            {
              "type": "function",
              "name": "interact",
              "inputs": [
                {
                  "name": "default_params",
                  "type": "pixelaw::core::utils::DefaultParameters"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "create_game",
              "inputs": [
                {
                  "name": "origin",
                  "type": "pixelaw::core::utils::Position"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "create_game_guilds",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "guild_dispatcher",
                  "type": "pwar::systems::guilds::IGuildDispatcher"
                }
              ],
              "outputs": [
                {
                  "type": "core::array::Array::<core::integer::u32>"
                }
              ],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "get_game_id",
              "inputs": [
                {
                  "name": "position",
                  "type": "pixelaw::core::utils::Position"
                }
              ],
              "outputs": [
                {
                  "type": "core::integer::u32"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "get_game",
              "inputs": [
                {
                  "name": "id",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [
                {
                  "type": "pwar::models::game::Game"
                }
              ],
              "state_mutability": "view"
            },
            {
              "type": "function",
              "name": "place_pixel",
              "inputs": [
                {
                  "name": "app",
                  "type": "core::starknet::contract_address::ContractAddress"
                },
                {
                  "name": "default_params",
                  "type": "pixelaw::core::utils::DefaultParameters"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            },
            {
              "type": "function",
              "name": "end_game",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "impl",
          "name": "WorldProviderImpl",
          "interface_name": "dojo::contract::components::world_provider::IWorldProvider"
        },
        {
          "type": "struct",
          "name": "dojo::world::iworld::IWorldDispatcher",
          "members": [
            {
              "name": "contract_address",
              "type": "core::starknet::contract_address::ContractAddress"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::world_provider::IWorldProvider",
          "items": [
            {
              "type": "function",
              "name": "world_dispatcher",
              "inputs": [],
              "outputs": [
                {
                  "type": "dojo::world::iworld::IWorldDispatcher"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "UpgradeableImpl",
          "interface_name": "dojo::contract::components::upgradeable::IUpgradeable"
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::upgradeable::IUpgradeable",
          "items": [
            {
              "type": "function",
              "name": "upgrade",
              "inputs": [
                {
                  "name": "new_class_hash",
                  "type": "core::starknet::class_hash::ClassHash"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "constructor",
          "name": "constructor",
          "inputs": []
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
          "kind": "struct",
          "members": [
            {
              "name": "class_hash",
              "type": "core::starknet::class_hash::ClassHash",
              "kind": "data"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "Upgraded",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
              "kind": "nested"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::world_provider::world_provider_cpt::Event",
          "kind": "enum",
          "variants": []
        },
        {
          "type": "event",
          "name": "pwar::systems::actions::pwar_actions::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "UpgradeableEvent",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
              "kind": "nested"
            },
            {
              "name": "WorldProviderEvent",
              "type": "dojo::contract::components::world_provider::world_provider_cpt::Event",
              "kind": "nested"
            }
          ]
        }
      ],
      "init_calldata": [],
      "tag": "pwar-pwar_actions",
      "selector": "0x3daa6a1f5dad3f5074b948a3e3a65e5b5f08198629686def58f43acce601a48",
      "systems": [
        "dojo_init",
        "interact",
        "create_game",
        "create_game_guilds",
        "place_pixel",
        "end_game",
        "upgrade"
      ]
    },
    {
      "address": "0x379ac4b00a0ad23a102ea64d2686123300ef515605d0cea7df79405f4555ba",
      "class_hash": "0x336f77928b73a5f532bfa6975c71a11395ea86d2e8a9ea2e9c571efb15f8f4c",
      "abi": [
        {
          "type": "impl",
          "name": "voting_actions__ContractImpl",
          "interface_name": "dojo::contract::interface::IContract"
        },
        {
          "type": "interface",
          "name": "dojo::contract::interface::IContract",
          "items": []
        },
        {
          "type": "impl",
          "name": "voting_actions__DeployedContractImpl",
          "interface_name": "dojo::meta::interface::IDeployedResource"
        },
        {
          "type": "struct",
          "name": "core::byte_array::ByteArray",
          "members": [
            {
              "name": "data",
              "type": "core::array::Array::<core::bytes_31::bytes31>"
            },
            {
              "name": "pending_word",
              "type": "core::felt252"
            },
            {
              "name": "pending_word_len",
              "type": "core::integer::u32"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::meta::interface::IDeployedResource",
          "items": [
            {
              "type": "function",
              "name": "dojo_name",
              "inputs": [],
              "outputs": [
                {
                  "type": "core::byte_array::ByteArray"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "VotingImpl",
          "interface_name": "pwar::systems::voting::IVoting"
        },
        {
          "type": "enum",
          "name": "core::bool",
          "variants": [
            {
              "name": "False",
              "type": "()"
            },
            {
              "name": "True",
              "type": "()"
            }
          ]
        },
        {
          "type": "interface",
          "name": "pwar::systems::voting::IVoting",
          "items": [
            {
              "type": "function",
              "name": "vote",
              "inputs": [
                {
                  "name": "game_id",
                  "type": "core::integer::u32"
                },
                {
                  "name": "index",
                  "type": "core::integer::u32"
                },
                {
                  "name": "use_px",
                  "type": "core::integer::u32"
                },
                {
                  "name": "is_in_favor",
                  "type": "core::bool"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "function",
          "name": "dojo_init",
          "inputs": [],
          "outputs": [],
          "state_mutability": "view"
        },
        {
          "type": "impl",
          "name": "WorldProviderImpl",
          "interface_name": "dojo::contract::components::world_provider::IWorldProvider"
        },
        {
          "type": "struct",
          "name": "dojo::world::iworld::IWorldDispatcher",
          "members": [
            {
              "name": "contract_address",
              "type": "core::starknet::contract_address::ContractAddress"
            }
          ]
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::world_provider::IWorldProvider",
          "items": [
            {
              "type": "function",
              "name": "world_dispatcher",
              "inputs": [],
              "outputs": [
                {
                  "type": "dojo::world::iworld::IWorldDispatcher"
                }
              ],
              "state_mutability": "view"
            }
          ]
        },
        {
          "type": "impl",
          "name": "UpgradeableImpl",
          "interface_name": "dojo::contract::components::upgradeable::IUpgradeable"
        },
        {
          "type": "interface",
          "name": "dojo::contract::components::upgradeable::IUpgradeable",
          "items": [
            {
              "type": "function",
              "name": "upgrade",
              "inputs": [
                {
                  "name": "new_class_hash",
                  "type": "core::starknet::class_hash::ClassHash"
                }
              ],
              "outputs": [],
              "state_mutability": "external"
            }
          ]
        },
        {
          "type": "constructor",
          "name": "constructor",
          "inputs": []
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
          "kind": "struct",
          "members": [
            {
              "name": "class_hash",
              "type": "core::starknet::class_hash::ClassHash",
              "kind": "data"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "Upgraded",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Upgraded",
              "kind": "nested"
            }
          ]
        },
        {
          "type": "event",
          "name": "dojo::contract::components::world_provider::world_provider_cpt::Event",
          "kind": "enum",
          "variants": []
        },
        {
          "type": "event",
          "name": "pwar::systems::voting::voting_actions::Event",
          "kind": "enum",
          "variants": [
            {
              "name": "UpgradeableEvent",
              "type": "dojo::contract::components::upgradeable::upgradeable_cpt::Event",
              "kind": "nested"
            },
            {
              "name": "WorldProviderEvent",
              "type": "dojo::contract::components::world_provider::world_provider_cpt::Event",
              "kind": "nested"
            }
          ]
        }
      ],
      "init_calldata": [],
      "tag": "pwar-voting_actions",
      "selector": "0x62e6ca68a564d25337ca245b38054c9b249d3a9d3d7bb0d97a6a817e473383a",
      "systems": [
        "vote",
        "upgrade"
      ]
    }
  ]