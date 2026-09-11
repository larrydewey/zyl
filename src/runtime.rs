/// The runtime is embedded so an installed `zyl` does not depend on the
/// repository checkout that built it.
pub const RUNTIME_C_SOURCE: &str = include_str!("runtime/actor_runtime.c");

pub fn embedded_runtime_source() -> String {
    RUNTIME_C_SOURCE.replacen(
        "#include \"actor_runtime.h\"",
        include_str!("runtime/actor_runtime.h"),
        1,
    )
}
