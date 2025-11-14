use core::array::ArrayTrait;
use core::felt252;
use core::poseidon::{PoseidonTrait, poseidon_hash_span};
use core::traits::Into;

/// Simple fibonacci (iterative).
pub fn fib(n: u32) -> u32 {
    if n == 0_u32 {
        return 0_u32;
    }
    let mut a: u32 = 0_u32;
    let mut b: u32 = 1_u32;
    let mut i: u32 = 1_u32;
    loop {
        if i == n {
            break b;
        }
        let temp = b;
        b = a + b;
        a = temp;
        i = i + 1_u32;
    }
}

/// Integer floor sqrt via binary search.
pub fn sqrt(x: u32) -> u32 {
    if x == 0_u32 {
        return 0_u32;
    }
    let mut low: u32 = 1_u32;
    let mut high: u32 = x / 2_u32 + 1_u32;
    let mut ans: u32 = 1_u32;
    loop {
        if low > high {
            break ans;
        }
        let mid = low + (high - low) / 2_u32;
        if mid > x / mid {
            high = mid - 1_u32;
        } else {
            ans = mid;
            low = mid + 1_u32;
        }
    }
}

/// Hash a pair (a, b) as Poseidon over [a, b] (both u32 -> felt252).
pub fn hash_u32_pair(a: u32, b: u32) -> felt252 {
    let mut data = ArrayTrait::<felt252>::new();
    data.append(a.into());
    data.append(b.into());
    poseidon_hash_span(data.span())
}

/// (Generalization) Hash IO as Poseidon over
///   [ 0x49_4F, in_len, inputs..., out_len, outputs... ]
/// so commitments are unambiguous for N-in / M-out.
///
/// You can keep using hash_u32_pair for the 1-in/1-out case if you prefer strict
/// compatibility with your existing files; this helper is here for future NxM calls.
pub fn hash_u32_io_commit(in_len: u32, inputs: Array<u32>, out_len: u32, outputs: Array<u32>) -> felt252 {
    let mut felts = ArrayTrait::<felt252>::new();
    // "IO" tag to namespace this format (arbitrary constant)
    felts.append(0x494F.into());
    felts.append(in_len.into());
    let mut i: u32 = 0_u32;
    loop {
        if i == in_len { break (); }
        let val_u32: u32 = *inputs.at(i.into());
        felts.append(val_u32.into());
        i = i + 1_u32;
    }
    felts.append(out_len.into());
    let mut j: u32 = 0_u32;
    loop {
        if j == out_len { break (); }
        let val_u32: u32 = *outputs.at(j.into());
        felts.append(val_u32.into());
        j = j + 1_u32;
    }
    poseidon_hash_span(felts.span())
}
