/// The runtime is embedded so an installed `zyl` does not depend on the
/// repository checkout that built it.
///
/// Path is `../../../runtime/` (not `../runtime/`) because this crate
/// lives at `archive/rust-bootstrap-2026/` since Rust was evicted from
/// the active build path (see docs/rust-eviction-plan.md) — the real
/// `runtime/actor_runtime.{c,h}` is at the actual repo root, three
/// levels up from here.
pub const RUNTIME_C_SOURCE: &str = include_str!("../../../runtime/actor_runtime.c");

pub fn embedded_runtime_source() -> String {
    RUNTIME_C_SOURCE.replacen(
        "#include \"actor_runtime.h\"",
        include_str!("../../../runtime/actor_runtime.h"),
        1,
    )
}
