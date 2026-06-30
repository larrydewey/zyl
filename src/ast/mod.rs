//! Abstract Syntax Tree for Zyl
//! 
//! Defines all AST nodes per specification section 2.

use std::fmt;


// ============================================================================
// LITERAL TYPES (Section 3: Value Model)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub enum AtomKind {
    Int(i64),
    Float(f64),
    Bool(bool),
    StringLit(String),
    Ident(String),
}

impl Eq for AtomKind {}

impl std::hash::Hash for AtomKind {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        match self {
            AtomKind::Int(v) => { 0u8.hash(state); v.hash(state); }
            AtomKind::Float(v) => { 1u8.hash(state); v.to_bits().hash(state); }
            AtomKind::Bool(v) => { 2u8.hash(state); v.hash(state); }
            AtomKind::StringLit(v) => { 3u8.hash(state); v.hash(state); }
            AtomKind::Ident(v) => { 4u8.hash(state); v.hash(state); }
        }
    }
}

impl fmt::Display for AtomKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AtomKind::Int(v) => write!(f, "{}", v),
            AtomKind::Float(v) => write!(f, "{}", v),
            AtomKind::Bool(v) => write!(f, "{}", v),
            AtomKind::StringLit(v) => write!(f, "\"{}\"", v),
            AtomKind::Ident(v) => write!(f, "{}", v),
        }
    }
}

// ============================================================================
// ADDRESS TYPE (Spec §3 — FFI pinning results)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Address {
    pub region: Region,
    pub id: usize,
}

impl fmt::Display for Address {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Address({}, {})", self.region, self.id)
    }
}

// ============================================================================
// REGION ANNOTATIONS (Section 5)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Region {
    Stack,   // R1: Local stack allocation
    Heap,    // R2: Escape allocation
    Global,  // Global/static data
    Circular,// Cyclic structures
    Pin,     // FFI-pinned memory
}

impl fmt::Display for Region {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Region::Stack => write!(f, "stack"),
            Region::Heap => write!(f, "heap"),
            Region::Global => write!(f, "global"),
            Region::Circular => write!(f, "circular"),
            Region::Pin => write!(f, "pin"),
        }
    }
}

// ============================================================================
// CAPABILITY TYPES (Section 4)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum CapType {
    Immutable,     // TCap<T> - immutable shared
    Mutable,       // TMut<T> - exclusive mutable
    Atomic,        // TAtomic<T> - atomic shared mutation
    Boxed,         // TBox<T> - heap-managed allocation
    Pinned,        // TPin<T> - FFI-pinned memory
}

impl fmt::Display for CapType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CapType::Immutable => write!(f, "TCap"),
            CapType::Mutable => write!(f, "TMut"),
            CapType::Atomic => write!(f, "TAtomic"),
            CapType::Boxed => write!(f, "TBox"),
            CapType::Pinned => write!(f, "TPin"),
        }
    }
}

// ============================================================================
// PRIMITIVE TYPES (Section 4)
// ============================================================================

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum PrimType {
    Int,      // Int64
    Float,    // Float64 (IEEE-754 binary64)
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

// ============================================================================
// TYPE EXPRESSIONS (Section 4)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum TypeExpr {
    Prim(PrimType),
    Cap { cap: CapType, inner: Box<TypeExpr> },
    Fun { args: Vec<TypeExpr>, ret: Box<TypeExpr> },
    Tuple(Vec<TypeExpr>),
    Region { inner: Box<TypeExpr>, region: Region },
    Generic(String),           // Type parameter
    App { name: String, args: Vec<TypeExpr> }, // Applied generic
}

impl fmt::Display for TypeExpr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TypeExpr::Prim(t) => write!(f, "{}", t),
            TypeExpr::Cap { cap, inner } => write!(f, "{}<{}>", cap, inner),
            TypeExpr::Fun { args, ret } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "TFun([{}], {})", args_str.join(", "), ret)
            }
            TypeExpr::Tuple(types) => {
                let types_str: Vec<String> = types.iter().map(|t| t.to_string()).collect();
                write!(f, "({})", types_str.join(", "))
            }
            TypeExpr::Region { inner, region } => write!(f, "{}@{}", inner, region),
            TypeExpr::Generic(name) => write!(f, "{}", name),
            TypeExpr::App { name, args } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "{}<{}>", name, args_str.join(","))
            }
        }
    }
}

// ============================================================================
// AST NODES (Section 2)
// ============================================================================

/// A Zyl expression - the core AST node
#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    /// Atom: Integer | Float | Boolean | String | Identifier
    Atom(AtomKind),
    
    /// (Op Expr*) - Application / function call (operator is an identifier/literal)
    App(String, Vec<Expr>),
    
    /// (Expr Expr* ...) - Application where the operator is itself an expression
    /// Used for higher-order calls like ((compose inc inc) 5)
    AppExpr(Box<Expr>, Vec<Expr>),
    
    /// (def Name Expr) - Top-level definition
    Def(String, Box<Expr>),
    
    /// (defn Name (Params*) Body) - Function definition
    Defn {
        name: String,
        params: Vec<String>,
        body: Box<Expr>,
        ret_type: Option<TypeExpr>,
    },
    
    /// (let (Name Expr) Body) - Immutable binding
    Let {
        name: String,
        value: Box<Expr>,
        body: Box<Expr>,
    },
    
    /// (let-mut (Name Expr) Body) - Mutable binding
    LetMut {
        name: String,
        value: Box<Expr>,
        body: Box<Expr>,
    },
    
    /// (if Expr Expr Expr) - Conditional
    If {
        cond: Box<Expr>,
        then_branch: Box<Expr>,
        else_branch: Box<Expr>,
    },
    
    /// (try Expr (catch Name Expr)) - Exception handling
    TryCatch {
        body: Box<Expr>,
        catch_var: String,
        handler: Box<Expr>,
    },
    
    /// (spawn Expr) - Create actor
    Spawn(Box<Expr>),
    
    /// (send Expr Expr) - Send message to actor
    Send {
        target: Box<Expr>,
        message: Box<Expr>,
    },
    
    /// (ffi-call String Expr* Integer) - FFI call with timeout
    FfiCall {
        name: String,
        args: Vec<Expr>,
        timeout_ms: i64,
    },
    
    /// (ffi-pin Expr) - Pin expression for FFI
    FfiPin(Box<Expr>),
    
    /// (assert Expr String) - Assertion with message
    Assert {
        condition: Box<Expr>,
        message: String,
    },
    
    /// (fn (param*) body) - Anonymous function / closure (§7)
    Fn {
        params: Vec<String>,
        body: Box<Expr>,
    },
    
    /// (while Expr Expr) - Loop (§12.5)
    While {
        condition: Box<Expr>,
        body: Box<Expr>,
    },
    
    /// (for Name Expr Expr Body) - For loop (§12.6)
    For {
        name: String,
        iterator: Box<Expr>,
        body: Box<Expr>,
    },
    
    /// (cond Clause*) - Conditional dispatch (§12.7)
    Cond(Vec<(Expr, Expr)>),
    
    /// (match Expr (Variant pattern* body) ...) - Pattern matching (§8)
    Match {
        scrutinee: Box<Expr>,
        clauses: Vec<MatchClause>,
    },
    
    /// (deftype Name (Variant*) VariantBound?) - ADT declaration (§8)
    Deftype {
        name: String,
        variants: Vec<AdtVariant>,
    },
    
    /// (trait Name (TraitMethod*) TraitBound?) - Trait declaration (§5)
    TraitDecl {
        name: String,
        methods: Vec<TraitMethod>,
        bound: Option<String>,
    },
    
    /// (impl TraitName TypeName (ImplBody*)) - Trait implementation (§5)
    Impl {
        trait_name: String,
        type_name: String,
        body: Vec<Expr>,
    },
    
    /// (use module-name { symbol }) - Import (§24)
    Use {
        module: String,
        symbols: Vec<UseSymbol>,
    },
    
    /// (export symbol) - Export (§24)
    Export(Box<Expr>),
    
    /// (pub (defn ...)) - Public definition (§24)
    Pub(Box<Expr>),
    
    /// (requires Condition) - Precondition contract (§23)
    Requires(Box<Expr>),
    
    /// (ensures Condition) - Postcondition contract (§23)
    Ensures {
        condition: Box<Expr>,
        body: Box<Expr>,
    },
    
    /// (invariant Condition) - Invariant contract (§23)
    Invariant(Box<Expr>),
    
    /// (recover ((ErrorType) fallback-expr) ...) - Recovery block (§23)
    Recover {
        handlers: Vec<(String, Expr)>,
        body: Box<Expr>,
    },
    
    /// (checkpoint expr) - Checkpoint scope (§23)
    Checkpoint(Box<Expr>),
    
    /// (contracts off|warn|strict|debug|production) - Contract profile (§23)
    Contracts(String),
    
    /// (begin Expr+) - Sequencing (§12.8)
    Begin(Vec<Expr>),
    
    // ========================================================================
    // TESTING FRAMEWORK (§20.5 — v3.3)
    // ========================================================================
    
    /// (test-suite "name" (:keyword value*)* body...) - Test suite registration
    TestSuite {
        name: String,
        tests: Vec<Expr>,
        keywords: Vec<(String, String)>,  // keyword -> string representation
    },
    
    /// (test "name" (:keyword value*)* body...) - Test registration
    Test {
        name: String,
        body: Box<Expr>,
        keywords: Vec<(String, String)>,  // keyword -> string representation
    },
    
    /// (assert-equal expected actual) - Assert value equality
    AssertEqual {
        expected: Box<Expr>,
        actual: Box<Expr>,
    },
    
    /// (assert-fail expr [msg]) - Assert expression raises error
    AssertFail {
        expr: Box<Expr>,
        message: Option<String>,
    },
    
    /// (assert-true expr [msg]) - Assert boolean true
    AssertTrue {
        expr: Box<Expr>,
        message: Option<String>,
    },
    
    /// (assert-false expr [msg]) - Assert boolean false
    AssertFalse {
        expr: Box<Expr>,
        message: Option<String>,
    },
    
    /// (test-property "name" generator property-fn) - Property-based testing
    TestProperty {
        name: String,
        generator: Generator,
        property_fn: Box<Expr>,
    },
    
    /// (setup body...) - Test fixture setup
    Setup(Vec<Expr>),
    
    /// (teardown body...) - Test fixture teardown
    Teardown(Vec<Expr>),
    
    /// (run-tests (:keyword value*)*) - Test runner
    RunTests {
        verbose: bool,
        fail_fast: bool,
        parallel: bool,
    },
    
    /// (test-compile expr :expect-error) - Compile-time test
    TestCompile {
        expr: Box<Expr>,
        expect_error: bool,
    },
    
    /// (quote Expr) — Return the expression literally without evaluating it
    Quote(Box<Expr>),
}

#[allow(dead_code)]
impl Expr {
    /// Create a let binding: (let (name value) body)
    pub fn let_binding(name: impl Into<String>, value: Expr, body: Expr) -> Self {
        Expr::Let {
            name: name.into(),
            value: Box::new(value),
            body: Box::new(body),
        }
    }
    
    /// Create a let-mut binding: (let-mut (name value) body)
    pub fn let_mut_binding(name: impl Into<String>, value: Expr, body: Expr) -> Self {
        Expr::LetMut {
            name: name.into(),
            value: Box::new(value),
            body: Box::new(body),
        }
    }
    
    /// Create a function definition
    pub fn defn(name: impl Into<String>, params: Vec<String>, body: Expr) -> Self {
        Expr::Defn {
            name: name.into(),
            params,
            body: Box::new(body),
            ret_type: None,
        }
    }
    
    /// Create a conditional
    pub fn if_expr(cond: Expr, then_branch: Expr, else_branch: Expr) -> Self {
        Expr::If {
            cond: Box::new(cond),
            then_branch: Box::new(then_branch),
            else_branch: Box::new(else_branch),
        }
    }
    
    /// Create a function application
    pub fn app(name: impl Into<String>, args: Vec<Expr>) -> Self {
        Expr::App(name.into(), args)
    }
    
    /// Create an atom
    pub fn atom(kind: AtomKind) -> Self {
        Expr::Atom(kind)
    }
    
    /// Create a try-catch expression
    pub fn try_catch(body: Expr, catch_var: impl Into<String>, handler: Expr) -> Self {
        Expr::TryCatch {
            body: Box::new(body),
            catch_var: catch_var.into(),
            handler: Box::new(handler),
        }
    }
    
    /// Create an assert expression
    pub fn assert_expr(cond: Expr, msg: impl Into<String>) -> Self {
        Expr::Assert {
            condition: Box::new(cond),
            message: msg.into(),
        }
    }
}

// ============================================================================
// TESTING FRAMEWORK GENERATORS (§20.5.4 — v3.3)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub enum Generator {
    GenInt,
    GenBool,
    GenString,
    GenFloat,
}

impl fmt::Display for Generator {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Generator::GenInt => write!(f, "gen-int"),
            Generator::GenBool => write!(f, "gen-bool"),
            Generator::GenString => write!(f, "gen-string"),
            Generator::GenFloat => write!(f, "gen-float"),
        }
    }
}

impl fmt::Display for Expr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Expr::Atom(a) => write!(f, "{}", a),
            Expr::App(op, args) => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "({} {})", op, args_str.join(" "))
            }
            Expr::AppExpr(operator, args) => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "(({}) {})", operator, args_str.join(" "))
            }
            Expr::Def(name, body) => write!(f, "(def {} {})", name, body),
            Expr::Defn { name, params, body, .. } => {
                let params_str: Vec<String> = params.iter().map(|p| p.to_string()).collect();
                write!(f, "(defn {} ({}) {})", name, params_str.join(" "), body)
            }
            Expr::Let { name, value, body } => {
                write!(f, "(let ({name} {}) {})", value, body)
            }
            Expr::LetMut { name, value, body } => {
                write!(f, "(let-mut ({name} {}) {})", value, body)
            }
            Expr::If { cond, then_branch, else_branch } => {
                write!(f, "(if {} {} {})", cond, then_branch, else_branch)
            }
            Expr::TryCatch { body, catch_var, handler } => {
                write!(f, "(try {} (catch {} {}))", body, catch_var, handler)
            }
            Expr::Spawn(inner) => write!(f, "(spawn {})", inner),
            Expr::Send { target, message } => {
                write!(f, "(send {} {})", target, message)
            }
            Expr::FfiCall { name, args, timeout_ms } => {
                let args_str: Vec<String> = args.iter().map(|a| a.to_string()).collect();
                write!(f, "(ffi-call \"{}\" {} {})", name, args_str.join(" "), timeout_ms)
            }
            Expr::FfiPin(inner) => write!(f, "(ffi-pin {})", inner),
            Expr::Assert { condition, message } => {
                write!(f, "(assert {} \"{}\")", condition, message)
            }
            Expr::Fn { params, body } => {
                let params_str: Vec<String> = params.iter().map(|p| p.to_string()).collect();
                write!(f, "(fn ({}) {})", params_str.join(" "), body)
            }
            Expr::While { condition, body } => {
                write!(f, "(while {} {})", condition, body)
            }
            Expr::For { name, iterator, body } => {
                write!(f, "(for {} {} {})", name, iterator, body)
            }
            Expr::Cond(clauses) => {
                let clause_strs: Vec<String> = clauses.iter()
                    .map(|(cond, body)| format!("({} {})", cond, body))
                    .collect();
                write!(f, "(cond {})", clause_strs.join(" "))
            }
            Expr::Match { scrutinee, clauses } => {
                let clause_strs: Vec<String> = clauses.iter()
                    .map(|c| format!("({} {} {})", c.variant, 
                        c.patterns.iter().map(|p| match p {
                            MatchPattern::Wildcard => "_".into(),
                            MatchPattern::Bind(n) => n.clone(),
                            MatchPattern::Literal(l) => l.to_string(),
                        }).collect::<Vec<_>>().join(" "),
                        c.body))
                    .collect();
                write!(f, "(match {} {})", scrutinee, clause_strs.join(" "))
            }
            Expr::Deftype { name, variants } => {
                let var_strs: Vec<String> = variants.iter()
                    .map(|v| format!("({} {})", v.name,
                        v.fields.iter().map(|f| f.to_string()).collect::<Vec<_>>().join(" ")))
                    .collect();
                write!(f, "(deftype {} {})", name, var_strs.join(" "))
            }
            Expr::TraitDecl { name, methods, bound } => {
                let method_strs: Vec<String> = methods.iter()
                    .map(|m| format!("({} ({}) {})", m.name, m.params.join(" "), m.return_type))
                    .collect();
                write!(f, "(trait {} {}", name, method_strs.join(" "))?;
                if let Some(b) = bound {
                    write!(f, " where {}", b)?;
                }
                write!(f, ")")
            }
            Expr::Impl { trait_name, type_name, body } => {
                let body_str: Vec<String> = body.iter().map(|b| b.to_string()).collect();
                write!(f, "(impl {} {} {})", trait_name, type_name, body_str.join(" "))
            }
            Expr::Use { module, symbols } => {
                let sym_strs: Vec<String> = symbols.iter()
                    .map(|s| match &s.alias {
                        Some(alias) => format!("{} => {}", s.name, alias),
                        None => s.name.clone(),
                    })
                    .collect();
                write!(f, "(use {} {{ {} }})", module, sym_strs.join(" "))
            }
            Expr::Export(body) => write!(f, "(export {})", body),
            Expr::Pub(body) => write!(f, "(pub {})", body),
            Expr::Requires(condition) => write!(f, "(requires {})", condition),
            Expr::Ensures { condition, body } => {
                write!(f, "(ensures {} {})", condition, body)
            }
            Expr::Invariant(condition) => write!(f, "(invariant {})", condition),
            Expr::Recover { handlers, body } => {
                let handler_strs: Vec<String> = handlers.iter()
                    .map(|(err, fallback)| format!("(({}) {})", err, fallback))
                    .collect();
                write!(f, "(recover {} {})", handler_strs.join(" "), body)
            }
            Expr::Checkpoint(body) => write!(f, "(checkpoint {})", body),
            Expr::Contracts(profile) => write!(f, "(contracts {})", profile),
            Expr::Begin(exprs) => {
                let expr_strs: Vec<String> = exprs.iter().map(|e| e.to_string()).collect();
                write!(f, "(begin {})", expr_strs.join(" "))
            }
            // Testing framework (§20.5 — v3.3)
            Expr::TestSuite { name, tests, keywords } => {
                let kw_str: String = keywords.iter()
                    .map(|(k, v)| format!(":{} {}", k, v))
                    .collect::<Vec<_>>()
                    .join(" ");
                let test_strs: Vec<String> = tests.iter().map(|t| t.to_string()).collect();
                if kw_str.is_empty() {
                    write!(f, "(test-suite \"{}\" {})", name, test_strs.join(" "))
                } else {
                    write!(f, "(test-suite \"{}\" {} {})", name, kw_str, test_strs.join(" "))
                }
            }
            Expr::Test { name, body, keywords } => {
                let kw_str: String = keywords.iter()
                    .map(|(k, v)| format!(":{} {}", k, v))
                    .collect::<Vec<_>>()
                    .join(" ");
                if kw_str.is_empty() {
                    write!(f, "(test \"{}\" {})", name, body)
                } else {
                    write!(f, "(test \"{}\" {} {})", name, kw_str, body)
                }
            }
            Expr::AssertEqual { expected, actual } => {
                write!(f, "(assert-equal {} {})", expected, actual)
            }
            Expr::AssertFail { expr, message } => {
                match message {
                    Some(msg) => write!(f, "(assert-fail {} \"{}\")", expr, msg),
                    None => write!(f, "(assert-fail {})", expr),
                }
            }
            Expr::AssertTrue { expr, message } => {
                match message {
                    Some(msg) => write!(f, "(assert-true {} \"{}\")", expr, msg),
                    None => write!(f, "(assert-true {})", expr),
                }
            }
            Expr::AssertFalse { expr, message } => {
                match message {
                    Some(msg) => write!(f, "(assert-false {} \"{}\")", expr, msg),
                    None => write!(f, "(assert-false {})", expr),
                }
            }
            Expr::TestProperty { name, generator, property_fn } => {
                write!(f, "(test-property \"{}\" {} {})", name, generator, property_fn)
            }
            Expr::Setup(bodies) => {
                let body_strs: Vec<String> = bodies.iter().map(|b| b.to_string()).collect();
                write!(f, "(setup {})", body_strs.join(" "))
            }
            Expr::Teardown(bodies) => {
                let body_strs: Vec<String> = bodies.iter().map(|b| b.to_string()).collect();
                write!(f, "(teardown {})", body_strs.join(" "))
            }
            Expr::RunTests { verbose, fail_fast, parallel } => {
                let mut parts = vec![];
                if *verbose { parts.push(":verbose true"); }
                if *fail_fast { parts.push(":fail-fast true"); }
                if !*parallel { parts.push(":parallel false"); }
                if parts.is_empty() {
                    write!(f, "(run-tests)")
                } else {
                    write!(f, "(run-tests {})", parts.join(" "))
                }
            }
            Expr::TestCompile { expr, expect_error } => {
                if *expect_error {
                    write!(f, "(test-compile {} :expect-error)", expr)
                } else {
                    write!(f, "(test-compile {})", expr)
                }
            }
            Expr::Quote(inner) => {
                write!(f, "(quote {})", inner)
            }
        }
    }
}

// ============================================================================
// PROGRAM (Top-level: list of definitions + expressions)
// ============================================================================

#[derive(Debug, Clone)]
pub struct Program {
    pub defs: Vec<Expr>,       // Top-level definitions
    pub body: Expr,            // Main expression
}

impl Program {
    pub fn new(defs: Vec<Expr>, body: Expr) -> Self {
        Self { defs, body }
    }
    
    pub fn empty() -> Self {
        Self {
            defs: Vec::new(),
            body: Expr::Atom(AtomKind::Ident("unit".into())),
        }
    }
}

impl fmt::Display for Program {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for def in &self.defs {
            writeln!(f, "{}", def)?;
        }
        write!(f, "{}", self.body)
    }
}

// ============================================================================
// MACRO DEFINITIONS (Section 15)
// ============================================================================

#[allow(dead_code)]
#[derive(Debug, Clone)]
pub struct MacroDef {
    pub name: String,
    pub pattern: Vec<Expr>,   // Pattern to match
    pub template: Expr,       // Template to produce
}

impl fmt::Display for MacroDef {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let pattern_str: Vec<String> = self.pattern.iter().map(|p| p.to_string()).collect();
        write!(f, "(macro {} {}) => {}", 
               self.name, 
               pattern_str.join(" "), 
               self.template)
    }
}

// ============================================================================
// MATCH CLAUSES (Section 8.3)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub struct MatchClause {
    /// Variant name to match against
    pub variant: String,
    /// Patterns for each field (or wildcards)
    pub patterns: Vec<MatchPattern>,
    /// Body expression when matched
    pub body: Box<Expr>,
}

/// A pattern in a match clause
#[derive(Debug, Clone, PartialEq)]
pub enum MatchPattern {
    /// Wildcard - matches any value
    Wildcard,
    /// Named binding - binds the field to this name
    Bind(String),
    /// Literal pattern - matches exactly this value
    Literal(AtomKind),
}

// ============================================================================
// ADT VARIANTS (Section 8)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub struct AdtVariant {
    pub name: String,
    pub fields: Vec<TypeExpr>,
}

// ============================================================================
// TRAIT METHODS (Section 5)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub struct TraitMethod {
    pub name: String,
    pub params: Vec<String>,
    pub return_type: TypeExpr,
}

// ============================================================================
// USE SYMBOLS (Section 24)
// ============================================================================

#[derive(Debug, Clone, PartialEq)]
pub struct UseSymbol {
    /// The symbol name being imported
    pub name: String,
    /// Optional alias (symbol => alias)
    pub alias: Option<String>,
}

// ============================================================================
// SOURCE LOCATION (for error reporting - Section 19)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Location {
    pub line: usize,
    pub col: usize,
}

impl Location {
    pub fn new(line: usize, col: usize) -> Self {
        Self { line, col }
    }
}

impl fmt::Display for Location {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}:{}", self.line, self.col)
    }
}
