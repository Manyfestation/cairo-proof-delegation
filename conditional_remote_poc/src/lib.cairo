mod primitives;
mod remote_macros;
mod local_prover;
mod remote_prover;

// Re-exports for tests / downstream
pub use primitives::{fib, sqrt, hash_u32_pair, hash_u32_io_commit};
pub use local_prover::prove_local_pair;
pub use remote_prover::prove_remote_sqrt_pair;

#[cfg(test)]
mod tests {
    use crate::primitives::{fib, sqrt, hash_u32_pair};
    use crate::local_prover::prove_local_pair;
    use crate::remote_prover::prove_remote_sqrt_pair;
    use core::felt252;

    #[test]
    fn end_to_end_conditional_proof() {
        // ============================
        // (0) Orchestrator picks secret n and runs both progs OFF-CHAIN
        //     solely to construct the public commitments to be used in proofs.
        //     (In a real system, parties might coordinate on c_remote without
        //      revealing witnesses; here we compute them to show a full demo.)
        // ============================
        let n: u32 = 10;
        let f: u32 = fib(n);
        let s: u32 = sqrt(f);

        // Commitments
        let c_local: felt252  = hash_u32_pair(n, s); // H(n, s)
        let c_remote: felt252 = hash_u32_pair(f, s); // H(f', s') where f'=f, s'=s

        // ============================
        // (1) Prover 1 (LOCAL) proves conditional statement:
        //     Uses c_remote in a macro-expanded "remote call" block,
        //     but does NOT compute sqrt itself.
        //     It *does* need the remote witnesses (f', s') to link equality
        //     and to check the commitment matches c_remote.
        // ============================
        let (c1_out, c2_out) = prove_local_pair(
            c_local, c_remote,
            n, s,
            f, s  // remote witnesses supplied to local proof
        );

        // Public outputs consistency
        assert!(c1_out == c_local, "Verifier: C1 mismatch after local proof");
        assert!(c2_out == c_remote, "Verifier: C2 mismatch after local proof");

        // ============================
        // (2) Prover 2 (REMOTE) proves the sqrt statement for the same c_remote
        // ============================
        let c_remote_verified = prove_remote_sqrt_pair(c_remote, f, s);
        assert!(c_remote_verified == c_remote, "Verifier: C2 mismatch after remote proof");

        // If we got here, both proofs are consistent via the shared c_remote.
    }
}