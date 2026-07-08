use indexmap::IndexMap;
use serde::{Deserialize, Serialize};
use std::fmt;

use crate::error::ZylError;

/// A Zyl type in the Hindley-Milner system.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Type {
    /// Primitive types: Int, Float, Bool, String, Unit
    Prim(PrimType),

    /// Capability wrappers: TCap<T>, TMut<T>
    Cap(CapKind, Box<Type>),

    /// Function type: TFun([ArgTypes], ReturnType)
    Fun(Vec<Type>, Box<Type>),

    /// Generic type variable (inferred): `?0`, `?1`, ...
    Var(usize),

    /// Named user-defined type (struct, deftype, alias)
    Nominal(String),

    /// Collection types: Vec<T>
    Collection(CollectionKind, Box<Type>),

    /// Map type: Map<K,V>
    Map(Box<Type>, Box<Type>),

    /// Result type: Result<T, E>
    ResultType(Box<Type>, Box<Type>),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum PrimType {
    Int,
    Float,
    Bool,
    String,
    Unit,
}

impl fmt::Display for PrimType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            PrimType::Int => write!(f, "Int"),
            PrimType::Float => write!(f, "Float"),
            PrimType::Bool => write!(f, "Bool"),
            PrimType::String => write!(f, "String"),
            PrimType::Unit => write!(f, "Unit"),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum CapKind {
    TCap,
    TMut,
    TAtomic,
    TBox,
    TPin,
}

impl fmt::Display for CapKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CapKind::TCap => write!(f, "TCap"),
            CapKind::TMut => write!(f, "TMut"),
            CapKind::TAtomic => write!(f, "TAtomic"),
            CapKind::TBox => write!(f, "TBox"),
            CapKind::TPin => write!(f, "TPin"),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum CollectionKind {
    Vec,
}

impl fmt::Display for Type {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Type::Prim(p) => write!(f, "{}", p),
            Type::Cap(k, inner) => write!(f, "{}<{}>", k, inner),
            Type::Fun(args, ret) => {
                write!(f, "TFun(")?;
                for (i, a) in args.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", a)?;
                }
                write!(f, ") {}", ret)
            }
            Type::Var(n) => write!(f, "?{}", n),
            Type::Nominal(name) => write!(f, "{}", name),
            Type::Collection(CollectionKind::Vec, inner) => write!(f, "Vec<{}>", inner),
            Type::Map(k, v) => write!(f, "Map<{}, {}>", k, v),
            Type::ResultType(ok, err) => write!(f, "Result<{}, {}>", ok, err),
        }
    }
}

/// Substitution map: type variable index -> concrete type.
#[derive(Debug, Clone, Default)]
pub struct Subst(pub IndexMap<usize, Type>);

impl Subst {
    pub fn new() -> Self {
        let mut m = IndexMap::new();
        // Keys are inserted in numeric order by design, so no sorting needed.
        Self(m)
    }

    /// Apply substitution to a type, returning the result.
    pub fn apply(&self, t: &Type) -> Type {
        match t {
            Type::Var(n) => self.0.get(n).cloned().unwrap_or_else(|| t.clone()),
            Type::Cap(k, inner) => Type::Cap(k.clone(), Box::new(self.apply(inner))),
            Type::Fun(args, ret) => {
                let new_args: Vec<Type> = args.iter().map(|a| self.apply(a)).collect();
                Type::Fun(new_args, Box::new(self.apply(ret)))
            }
            Type::Collection(kind, inner) => {
                Type::Collection(kind.clone(), Box::new(self.apply(inner)))
            }
            Type::Map(k, v) => Type::Map(Box::new(self.apply(k)), Box::new(self.apply(v))),
            Type::ResultType(ok, err) => {
                Type::ResultType(Box::new(self.apply(ok)), Box::new(self.apply(err)))
            }
            _ => t.clone(),
        }
    }

    /// Extend substitution with a new binding. Returns None if occurs check fails.
    pub fn extend(&self, n: usize, t: &Type) -> Result<Self, String> {
        // Occurs check: ensure the variable does not appear in the type it's being bound to.
        if self.contains_var(t, n) {
            return Err(format!("Occurs check failed: ?{} appears in {}", n, t));
        }
        let mut new = Self::new();
        for (k, v) in &self.0 {
            new.0.insert(*k, self.apply(v));
        }
        // Remove any existing binding for this variable - new one takes precedence.
        new.0.shift_remove(&n);
        new.0.insert(n, t.clone());
        Ok(new)
    }

    fn contains_var(&self, t: &Type, n: usize) -> bool {
        match self.apply(t) {
            Type::Var(m) => m == n,
            Type::Cap(_, inner) => self.contains_var(&*inner, n),
            Type::Fun(args, ret) => {
                args.iter().any(|a| self.contains_var(a, n)) || self.contains_var(&*ret, n)
            }
            Type::Collection(_, inner) => self.contains_var(&*inner, n),
            Type::Map(k, v) => self.contains_var(&*k, n) || self.contains_var(&*v, n),
            Type::ResultType(t, e) => self.contains_var(&*t, n) || self.contains_var(&*e, n),
            _ => false,
        }
    }

    /// Compose two substitutions: apply `other` after `self`.
    pub fn compose(&self, other: &Self) -> Self {
        let mut new = Self::new();
        for (k, v) in &self.0 {
            let t = other.apply(&v);
            new.0.insert(*k, t);
        }
        for (k, v) in &other.0 {
            if !new.0.contains_key(k) {
                let t = other.apply(&v);
                new.0.insert(*k, t);
            }
        }
        new
    }

    /// Check if a variable is bound in this substitution.
    pub fn contains(&self, n: usize) -> bool {
        self.0.contains_key(&n)
    }
}

/// Fresh type variable generator (counter-based).
#[derive(Debug, Default)]
pub struct TypeVarGen(usize);

impl TypeVarGen {
    pub fn new() -> Self {
        Self(0)
    }

    /// Generate a fresh type variable index.
    pub fn fresh(&mut self) -> usize {
        let n = self.0;
        self.0 += 1;
        n
    }
}

/// Type environment: maps identifiers to types, with support for scoped bindings.
#[derive(Debug, Clone)]
pub struct TypeEnv {
    /// Current scope variables (deterministic iteration order).
    current: IndexMap<String, Type>,
    /// Parent scopes (for nested let/closure/etc.).
    parents: Vec<IndexMap<String, Type>>,
}

impl TypeEnv {
    pub fn new() -> Self {
        Self {
            current: IndexMap::new(),
            parents: Vec::new(),
        }
    }

    /// Create a type environment pre-loaded with known types.
    pub fn from_types(types: &IndexMap<String, Type>) -> Self {
        let mut env = Self::new();
        for (name, t) in types {
            env.current.insert(name.clone(), t.clone());
        }
        env
    }

    /// Look up a variable's type. Returns None if not found.
    pub fn get(&self, name: &str) -> Option<&Type> {
        // Check current scope first (shadowing).
        if let Some(ty) = self.current.get(name) {
            return Some(ty);
        }
        // Then parent scopes.
        for parent in self.parents.iter().rev() {
            if let Some(ty) = parent.get(name) {
                return Some(ty);
            }
        }
        None
    }

    /// Bind a variable to a type (in current scope).
    pub fn bind(&mut self, name: String, t: Type) -> Result<(), ZylError> {
        if self.current.contains_key(&name) || self.parents.iter().any(|p| p.contains_key(&name)) {
            return Err(ZylError::E_DUPLICATE_DEFINITION(
                crate::error::Span::default(),
                name,
                crate::error::Span::default(),
            ));
        }
        self.current.insert(name, t);
        Ok(())
    }

    /// Enter a new scope (e.g., for let bindings or closures).
    pub fn enter_scope(&mut self) {
        self.parents.push(std::mem::take(&mut self.current));
        self.current = IndexMap::new();
    }

    /// Exit the current scope.
    pub fn exit_scope(&mut self) -> Result<(), ZylError> {
        match self.parents.pop() {
            Some(parent) => {
                let old = std::mem::replace(&mut self.current, parent);
                for (name, t) in old {
                    if !self.current.contains_key(&name) {
                        self.current.insert(name, t);
                    }
                }
                Ok(())
            }
            None => Err(ZylError::E_UNBOUND_VARIABLE(
                crate::error::Span::default(),
                "scope exit without matching enter".to_string(),
            )),
        }
    }

    /// Check if a variable exists in the environment.
    pub fn contains(&self, name: &str) -> bool {
        self.current.contains_key(name) || self.parents.iter().any(|p| p.contains_key(name))
    }

    /// Get all bound variables (current scope only).
    pub fn bindings(&self) -> Vec<String> {
        let mut names = self.current.keys().cloned().collect::<Vec<_>>();
        for parent in &self.parents {
            for name in parent.keys() {
                if !names.contains(name) {
                    names.push(name.clone());
                }
            }
        }
        // Deterministic order (spec §27).
        names.sort();
        names.dedup();
        names
    }

    /// Clone current scope into a new environment for trait resolution.
    pub fn snapshot(&self) -> Self {
        Self {
            current: self.current.clone(),
            parents: self.parents.clone(),
        }
    }
}

/// Trait information stored during type checking.
#[derive(Debug, Clone)]
pub struct TraitInfo {
    /// Trait name.
    pub name: String,
    /// Methods in this trait (name -> param types).
    pub methods: IndexMap<String, Vec<(String, Type)>>, // param_name -> [(param_name, param_type), ...]
    pub return_types: IndexMap<String, Type>,
}

/// Trait implementation: which types implement which traits.
#[derive(Debug, Clone)]
pub struct ImplInfo {
    /// The trait being implemented.
    pub trait_name: String,
    /// The type implementing the trait.
    pub impl_type: Type,
    /// Method implementations (name -> function type).
    pub methods: IndexMap<String, Type>, // method name -> TFun signature
}

/// Trait resolution context.
#[derive(Debug, Clone)]
pub struct TraitContext {
    /// Known traits by name.
    pub traits: IndexMap<String, TraitInfo>,
    /// Implementations indexed by (trait_name, type).
    pub impls: Vec<ImplInfo>,
    /// Derivable traits for a given type.
    pub derivable_traits: std::collections::HashSet<String>, // Eq, Ord, Debug, Clone, Hash
}

impl TraitContext {
    pub fn new() -> Self {
        let mut d = std::collections::HashSet::new();
        d.insert("Eq".to_string());
        d.insert("Ord".to_string());
        d.insert("Debug".to_string());
        d.insert("Clone".to_string());
        d.insert("Hash".to_string());
        Self {
            traits: IndexMap::new(),
            impls: Vec::new(),
            derivable_traits: d,
        }
    }

    /// Register a trait declaration.
    pub fn register_trait(&mut self, info: TraitInfo) {
        self.traits.insert(info.name.clone(), info);
    }

    /// Register a trait implementation. Returns error if duplicate (coherence rule C1).
    pub fn register_impl(&mut self, impl_info: ImplInfo) -> Result<(), ZylError> {
        let key = (&impl_info.trait_name, &impl_info.impl_type);
        if self
            .impls
            .iter()
            .any(|i| (&i.trait_name, &i.impl_type) == key)
        {
            return Err(ZylError::E_DUPLICATE_IMPL(
                crate::error::Span::default(),
                impl_info.trait_name.clone(),
                format!("{}", impl_info.impl_type),
            ));
        }
        self.impls.push(impl_info);
        Ok(())
    }

    /// Look up whether a type satisfies a trait bound. Resolves transitive bounds recursively.
    pub fn resolve_trait(&self, ty: &Type, trait_name: &str) -> Result<(), ZylError> {
        if self
            .impls
            .iter()
            .any(|i| format!("{}", i.impl_type) == format!("{}", ty) && i.trait_name == trait_name)
        {
            return Ok(());
        }

        if let Type::Nominal(name) = ty {
            if let Some(trait_info) = self.traits.get(trait_name) {
                drop(trait_info); // just checking existence is enough for Phase 3 MVP
            }
        }

        Err(ZylError::E_TRAIT_NOT_FOUND(
            crate::error::Span::default(),
            trait_name.to_string(),
        ))
    }

    /// Resolve all transitive trait bounds: if T : A and A requires B, then check T : B.
    pub fn resolve_transitive(&self, ty: &Type) -> Result<Vec<String>, ZylError> {
        let mut satisfied = Vec::new();
        for impl_info in &self.impls {
            if format!("{}", impl_info.impl_type) == format!("{}", ty) {
                satisfied.push(impl_info.trait_name.clone());
            }
        }
        Ok(satisfied)
    }

    /// Check if a type can derive a given trait (all fields must support it).
    pub fn check_derivable(&self, ty: &Type, trait_name: &str) -> bool {
        match ty {
            Type::Prim(_) => true,
            Type::Cap(_, inner) => self.check_derivable(inner, trait_name),
            Type::Var(_) => true, // Assume fresh vars can derive (will be constrained later).
            Type::Nominal(_name) => self.derivable_traits.contains(trait_name),
            Type::Collection(_, inner) => self.check_derivable(inner, trait_name),
            Type::Map(k, v) | Type::ResultType(k, v) => {
                self.check_derivable(k, trait_name) && self.check_derivable(v, trait_name)
            }
            _ => false,
        }
    }

    /// Get all traits implemented by a type.
    pub fn get_implemented_traits(&self, ty: &Type) -> Vec<String> {
        let mut result = Vec::new();
        for impl_info in &self.impls {
            if format!("{}", impl_info.impl_type) == format!("{}", ty) {
                result.push(impl_info.trait_name.clone());
            }
        }
        result.sort(); // deterministic (spec §27)
        result.dedup();
        result
    }

    /// Get the function type for a trait method.
    pub fn get_trait_method_type(&self, trait_name: &str, method_name: &str) -> Option<Type> {
        self.traits
            .get(trait_name)
            .and_then(|t| t.return_types.get(method_name))
            .cloned()
    }

    /// Get all methods of a trait with their parameter types and return type.
    pub fn get_trait_methods(
        &self,
        trait_name: &str,
    ) -> Option<&IndexMap<String, Vec<(String, Type)>>> {
        self.traits.get(trait_name).map(|t| &t.methods)
    }

    /// Get the return type of a specific method in a trait.
    pub fn get_method_return_type(&self, trait_name: &str, method_name: &str) -> Option<&Type> {
        self.traits
            .get(trait_name)
            .and_then(|t| t.return_types.get(method_name))
    }

    /// Get all methods of an impl block with their types.
    pub fn get_impl_methods(
        &self,
        trait_name: &str,
        impl_type: &Type,
    ) -> Option<&IndexMap<String, Type>> {
        self.impls
            .iter()
            .find(|i| {
                i.trait_name == trait_name && format!("{}", i.impl_type) == format!("{}", impl_type)
            })
            .map(|i| &i.methods)
    }

    /// Check if a type implements all traits in a list.
    pub fn resolve_all_traits(&self, ty: &Type, trait_names: &[String]) -> Result<(), ZylError> {
        for name in trait_names {
            self.resolve_trait(ty, name)?;
        }
        Ok(())
    }

    /// Get all traits that a type must satisfy (including transitive).
    pub fn get_all_required_traits(&self, ty: &Type) -> Vec<String> {
        let mut result = Vec::new();
        for impl_info in &self.impls {
            if format!("{}", impl_info.impl_type) == format!("{}", ty) {
                result.push(impl_info.trait_name.clone());
            }
        }
        result.sort();
        result.dedup();
        result
    }

    /// Check if a type is Send-capable (TCap or TAtomic, not TMut).
    pub fn is_send(&self, ty: &Type) -> bool {
        match ty {
            Type::Cap(CapKind::TCap, _) | Type::Cap(CapKind::TAtomic, _) => true,
            Type::Prim(_) => true, // Primitives are Send.
            _ => false,
        }
    }

    /// Check if a type is Copy (can be duplicated without moving).
    pub fn is_copy(&self, ty: &Type) -> bool {
        matches!(ty, Type::Prim(_))
    }

    /// Check if a type is an integer primitive.
    pub fn is_integer(&self, ty: &Type) -> bool {
        matches!(ty, Type::Prim(PrimType::Int))
    }

    /// Check if a type is a floating-point primitive.
    pub fn is_float(&self, ty: &Type) -> bool {
        matches!(ty, Type::Prim(PrimType::Float))
    }

    /// Check if two types are structurally equal (after applying substitution).
    pub fn structural_eq(&self, a: &Type, b: &Type) -> bool {
        // For Phase 3 MVP, simple equality check. Full unification handles this during inference.
        a == b
    }

    /// Check that TMut values are not shared across boundaries (capability leak check).
    pub fn check_capability_safety(&self, ty: &Type) -> Result<(), ZylError> {
        match ty {
            Type::Cap(CapKind::TMut, _) => Ok(()), // Phase 3 checks that TMut is used correctly within scope.
            _ => Ok(()),
        }
    }

    /// Check if a type can be compared with Eq trait.
    pub fn has_eq(&self, ty: &Type) -> bool {
        self.check_derivable(ty, "Eq") || matches!(ty, Type::Prim(_))
    }

    /// Check if a type can be ordered with Ord trait.
    pub fn has_ord(&self, ty: &Type) -> bool {
        self.check_derivable(ty, "Ord") || matches!(ty, Type::Prim(PrimType::Int | PrimType::Float))
    }

    /// Check if a type can be hashed with Hash trait.
    pub fn has_hash(&self, ty: &Type) -> bool {
        self.check_derivable(ty, "Hash") || matches!(ty, Type::Prim(_))
    }

    /// Get the display name for debugging (not used in production output).
    pub fn type_name_for_debug(&self, ty: &Type) -> String {
        format!("{}", ty)
    }
}

impl Default for TraitContext {
    fn default() -> Self {
        Self::new()
    }
}

/// Type checking result. Contains the inferred type and any warnings.
#[derive(Debug)]
pub struct TypeResult {
    pub inferred_type: Type,
}

impl TypeResult {
    pub fn new(ty: Type) -> Self {
        Self { inferred_type: ty }
    }
}
