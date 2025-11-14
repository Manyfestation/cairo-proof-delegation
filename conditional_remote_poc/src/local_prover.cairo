use core::felt252;
use crate::primitives::{fib, hash_u32_pair};
use crate::remote_macros::remote_call_pair;

/// Prove the local statement:
///   Exists n, s, f', s' such that
///     c_local = H(n, s)
///     c_remote = H(f', s')
///     fib(n) = f'
///     s = s'
///
/// It never calls sqrt; it only ties to the remote via the macro.
pub fn prove_local_pair(
    c_local: felt252,
    c_remote: felt252,
    n: u32,
    s: u32,
    f_remote_in: u32,    // f' (remote input, witness known to the local prover)
    s_remote_out: u32    // s' (remote output, witness known to the local prover)
) -> (felt252, felt252) {
    // 1) Check local commitment
    let expected_local = hash_u32_pair(n, s);
    assert!(expected_local == c_local, "LOCAL_COMMIT_MISMATCH");

    // 2) Local compute
    let f_local = fib(n);

    // 3) "Remote call" via macro (expands to: check remote commit & tie f_local == f_remote_in)
    let s_local = remote_call_pair(f_local, c_remote, f_remote_in, s_remote_out);

    // 4) Final local assertion
    assert!(s_local == s, "FINAL_S_MISMATCH");

    // 5) Expose commitments
    (c_local, c_remote)
}
