use crate::primitives::hash_u32_pair;

use core::felt252;

pub fn remote_call_pair(
    x_local: u32,
    remote_commit: felt252,
    x_remote: u32,
    y_remote: u32
) -> u32 {
    let __expected_remote = hash_u32_pair(x_remote, y_remote);
    assert!(__expected_remote == remote_commit, "REMOTE_COMMIT_MISMATCH");
    assert!(x_local == x_remote, "REMOTE_LINK_MISMATCH");
    y_remote
}
