use core::felt252;
use crate::primitives::{sqrt, hash_u32_pair};

pub fn prove_remote_sqrt_pair(
    c_remote: felt252,
    n_sqrt: u32,  // f'  (input to sqrt)
    f_sqrt: u32   // s'  (output of sqrt)
) -> felt252 {
    // Commitment check
    let c_prime = hash_u32_pair(n_sqrt, f_sqrt);
    assert!(c_prime == c_remote, "SQRT_COMMIT_MISMATCH");

    // Remote computation check
    let f_prime = sqrt(n_sqrt);
    assert!(f_prime == f_sqrt, "SQRT_COMPUTE_MISMATCH");

    c_remote
}
