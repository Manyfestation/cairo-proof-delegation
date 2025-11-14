mod main;
// mod interfaces;
// mod prog_fib;
// mod prog_sqrt;
// mod prog_stitch;

// // #[starknet::contract]
// mod ProofMarket {
//     use starknet::{ContractAddress, ClassHash};
//     use core::integer::u32;
//     use super::interfaces;
//     use interfaces::{IProgStitchDispatcher, IProgStitchDispatcherTrait};

//     #[storage]
//     struct Storage {
//         vProgs: LegacyMap<felt252, ClassHash>,
//     }

//     #[abi(embed_v0)]
//     impl ProofMarket of interfaces::IProofMarket<ContractState> {
//         fn register_vprog(ref self: ContractState, prog_id: felt252, class_hash: ClassHash) {
//             self.vProgs.write(prog_id, class_hash);
//         }

//         fn run_composition(self: @ContractState, n: u32) -> (u32, felt252, felt252, felt252) {
//             // Deploy the contracts
//             let fib_hash = self.vProgs.read(1);
//             let sqrt_hash = self.vProgs.read(2);
//             let stitch_hash = self.vProgs.read(3);

//             let (fib_addr, _) = starknet::deploy_syscall(fib_hash, 0, array![].span(), false).unwrap();
//             let (sqrt_addr, _) = starknet::deploy_syscall(sqrt_hash, 0, array![].span(), false).unwrap();
//             let (stitch_addr, _) = starknet::deploy_syscall(stitch_hash, 0, array![].span(), false).unwrap();

//             // Call the stitcher
//             let stitcher = IProgStitchDispatcher { contract_address: stitch_addr };
//             stitcher.stitch_all(fib_addr, sqrt_addr, n)
//         }
//     }
// }
