use core::array::ArrayTrait;
use core::felt252;
use core::poseidon::{PoseidonTrait, poseidon_hash_span};
use core::traits::{Into, TryInto};
use core::integer::u32;

// Commitment logic (simplified for runnable PoC)
fn u32_to_felt252(val: u32) -> felt252 {
    val.into()
}

fn commit_value(prog_id: felt252, value: felt252) -> felt252 {
    let mut data = ArrayTrait::<felt252>::new();
    data.append(prog_id);
    data.append(value);
    poseidon_hash_span(data.span())
}

fn merge_commits(commits: @Array<felt252>) -> felt252 {
    let mut data = ArrayTrait::<felt252>::new();
    let mut i = 0;
    loop {
        if i == commits.len() {
            break;
        }
        data.append(*commits.at(i));
        i += 1;
    };
    poseidon_hash_span(data.span())
}

// Program A: Fibonacci
fn prove_fib(n: u32) -> (u32, felt252) {
    let mut a: u32 = 0;
    let mut b: u32 = 1;
    let mut i: u32 = 0;
    loop {
        if i == n {
            break;
        }
        let temp = a;
        a = b;
        b = temp + b;
        i += 1;
    };
    let commit = commit_value(1, u32_to_felt252(a));
    (a, commit)
}

pub fn sqrt(x: u32) -> u32 {
    if x == 0 {
        return 0;
    }
    let mut low: u32 = 1;
    let mut high: u32 = x / 2 + 1;
    let mut ans: u32 = 1;
    loop {
        if low > high {
            break ans;
        }
        let mid = low + (high - low) / 2;
        if mid > x / mid {
            high = mid - 1;
        } else {
            ans = mid;
            low = mid + 1;
        }
    }
}

// Program B: Sqrt
fn prove_sqrt(fib_val: u32, commit_fib: felt252) -> (u32, felt252) {
    let sqrt_val = sqrt(fib_val);
    let commit = commit_value(2, u32_to_felt252(sqrt_val));
    (sqrt_val, commit)
}

// Program C: Stitching
fn stitch_all(n: u32) -> (u32, felt252, felt252, felt252) {
    // 1) Call ProgFib
    let (fib_val, commitA) = prove_fib(n);

    // 2) Verify commitA is consistent
    let expectedA = commit_value(1, u32_to_felt252(fib_val));
    assert(expectedA == commitA, 'STITCH_COMMIT_A_MISMATCH');

    // 3) Call ProgSqrt, passing fib_val & commitA
    let (sqrt_val, commitB) = prove_sqrt(fib_val, commitA);

    // 4) Verify commitB is consistent
    let expectedB = commit_value(2, u32_to_felt252(sqrt_val));
    assert(expectedB == commitB, 'STITCH_COMMIT_B_MISMATCH');

    // 5) Cross-check relation sqrt^2 == fib
    let sqrt_val_felt = u32_to_felt252(sqrt_val);
    let fib_val_felt = u32_to_felt252(fib_val);
    let sq = sqrt_val_felt * sqrt_val_felt;
    assert(sq == fib_val_felt, 'STITCH_RELATION_MISMATCH');

    // 6) Merge commitments
    let mut commits = array![commitA, commitB];
    let combined_anchor = merge_commits(@commits);

    (sqrt_val, commitA, commitB, combined_anchor)
}

// Main executable function
#[executable] 
fn main() {
    // Input value for fibonacci. Note: This will fail the sqrt check
    // because fib(10) = 55, which is not a perfect square.
    // Try n=12 (fib=144, sqrt=12) to see a successful run.
    let n = 12; 
    
    let (final_val, commitA, commitB, combined_anchor) = stitch_all(n);

    println!("--- Runnable PoC ---");
    println!("Input n: {}", n);
    let (fib_res, _) = prove_fib(n);
    println!("Fibonacci Result (fib(n)): {}", fib_res);
    println!("Final Result (sqrt(fib(n))): {}", final_val);
    println!("Commitment A (Fib): {}", commitA);
    println!("Commitment B (Sqrt): {}", commitB);
    println!("Combined Anchor: {}", combined_anchor);
    println!("--------------------");
}
