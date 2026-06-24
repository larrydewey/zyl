//! Actor concurrency model for Zyl
//! 
//! Per specification section 11:
//! - Private state + FIFO mailbox
//! - No shared mutable state
//! - Messages must be Send-capable
//! - Deterministic FIFO per actor

use crossbeam_channel::{bounded, Receiver, Sender};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use thiserror::Error;

// ============================================================================
// ACTOR VALUES (Section 3: Value Model)
// ============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct ActorId(pub usize);

impl std::fmt::Display for ActorId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "actor{}", self.0)
    }
}

/// A message that can be sent between actors (must be Send + 'static)
#[derive(Debug, Clone)]
pub enum ActorMessage {
    Int(i64),
    Float(f64),
    Bool(bool),
    String(String),
    Unit,
    Tuple(Vec<ActorMessage>),
    /// Reference to another actor
    ActorRef(ActorId),
    /// Closure-like message (for actor body)
    SpawnBody(Arc<Mutex<Vec<String>>>), // Serialized Zyl expression
}

impl ActorMessage {
    pub fn is_sendable(&self) -> bool {
        // All our message types are Send + 'static by construction
        true
    }
}

// ============================================================================
// ACTOR STATE
// ============================================================================

#[derive(Debug)]
pub struct ActorState {
    pub id: ActorId,
    /// Private state (immutable snapshot)
    pub state: HashMap<String, ActorMessage>,
    /// FIFO mailbox
    pub mailbox: Vec<ActorMessage>,
    /// Whether the actor is alive
    pub alive: bool,
}

impl ActorState {
    pub fn new(id: ActorId) -> Self {
        Self {
            id,
            state: HashMap::new(),
            mailbox: Vec::new(),
            alive: true,
        }
    }
    
    /// Update private state (atomically within the actor)
    pub fn update_state(&mut self, key: String, value: ActorMessage) {
        self.state.insert(key, value);
    }
    
    /// Read private state
    pub fn get_state(&self, key: &str) -> Option<&ActorMessage> {
        self.state.get(key)
    }
    
    /// Receive a message from the mailbox (FIFO)
    pub fn receive(&mut self) -> Option<ActorMessage> {
        if self.mailbox.is_empty() {
            None
        } else {
            Some(self.mailbox.remove(0))
        }
    }
    
    /// Check if mailbox is empty
    pub fn is_mailbox_empty(&self) -> bool {
        self.mailbox.is_empty()
    }
}

// ============================================================================
// ACTOR SYSTEM (Section 11)
// ============================================================================

#[derive(Debug, Error)]
pub enum ActorError {
    #[error("Actor {id} not found")]
    NotFound { id: ActorId },
    
    #[error("Actor {id} is not alive")]
    NotAlive { id: ActorId },
    
    #[error("Message is not sendable")]
    NotSendable,
    
    #[error("Mailbox full (backpressure)")]
    MailboxFull,
    
    #[error("Deadlock detected: circular actor dependency")]
    Deadlock,
}

/// The actor system manages all actors and their communication
pub struct ActorSystem {
    /// All known actors
    actors: HashMap<ActorId, Arc<Mutex<ActorState>>>,
    /// Next actor ID to assign
    next_id: usize,
    /// Sender channels for each actor (for async send)
    senders: HashMap<ActorId, Sender<ActorMessage>>,
}

impl ActorSystem {
    pub fn new() -> Self {
        Self {
            actors: HashMap::new(),
            next_id: 0,
            senders: HashMap::new(),
        }
    }
    
    /// Spawn a new actor with a given body expression
    pub fn spawn(&mut self, body: Vec<String>) -> ActorId {
        let id = ActorId(self.next_id);
        self.next_id += 1;
        
        let state = Arc::new(Mutex::new(ActorState::new(id)));
        
        // Create a bounded channel for async messaging
        let (sender, receiver) = bounded::<ActorMessage>(100); // mailbox capacity
        
        // Store the actor state
        self.actors.insert(id, state.clone());
        self.senders.insert(id, sender);
        
        // Spawn the actor thread
        std::thread::spawn(move || {
            Self::run_actor(id, state, receiver, body);
        });
        
        id
    }
    
    /// Send a message to an actor
    pub fn send(&self, target: ActorId, message: ActorMessage) -> Result<(), ActorError> {
        // Verify the message is sendable
        if !message.is_sendable() {
            return Err(ActorError::NotSendable);
        }
        
        // Check actor exists and is alive
        {
            let state = self.actors.get(&target)
                .ok_or_else(|| ActorError::NotFound { id: target })?;
            let state = state.lock().unwrap();
            if !state.alive {
                return Err(ActorError::NotAlive { id: target });
            }
        }
        
        // Send via channel (will block if mailbox is full)
        let sender = self.senders.get(&target)
            .ok_or_else(|| ActorError::NotFound { id: target })?;
        
        sender.send(message).map_err(|_| ActorError::MailboxFull)?;
        Ok(())
    }
    
    /// Get an actor's state (for inspection/debugging)
    pub fn get_state(&self, _id: ActorId) -> Result<Arc<Mutex<ActorState>>, ActorError> {
        self.actors.get(&_id).cloned()
            .ok_or_else(|| ActorError::NotFound { id: _id })
    }
    
    /// Kill an actor
    pub fn kill(&mut self, id: ActorId) -> Result<(), ActorError> {
        let state = self.actors.get(&id)
            .ok_or_else(|| ActorError::NotFound { id })?;
        
        let mut state = state.lock().unwrap();
        state.alive = false;
        state.mailbox.clear(); // Drain mailbox
        
        Ok(())
    }
    
    /// Check if an actor exists
    pub fn exists(&self, id: ActorId) -> bool {
        self.actors.contains_key(&id)
    }
    
    /// Get the number of active actors
    pub fn count(&self) -> usize {
        self.actors.len()
    }
    
    /// Run an actor's event loop (called in a thread)
    fn run_actor(
        _id: ActorId,
        state: Arc<Mutex<ActorState>>,
        receiver: Receiver<ActorMessage>,
        _body: Vec<String>,
    ) {
        // In a real implementation, this would interpret the Zyl body
        // For now, it processes messages from the mailbox
        for message in receiver {
            let mut actor_state = state.lock().unwrap();
            
            if !actor_state.alive {
                break;
            }
            
            // Process the message
            actor_state.mailbox.push(message);
            
            // In a full implementation, the body would be evaluated
            // with each message as input, updating private state
        }
    }
    
    /// Check for deadlocks (circular dependencies)
    pub fn check_deadlock(&self) -> Result<(), ActorError> {
        // Simple cycle detection using DFS
        let mut visited = HashSet::new();
        let mut rec_stack = HashSet::new();
        
        for &id in self.actors.keys() {
            if !visited.contains(&id) {
                if self.detect_cycle(id, &mut visited, &mut rec_stack) {
                    return Err(ActorError::Deadlock);
                }
            }
        }
        
        Ok(())
    }
    
    fn detect_cycle(
        &self,
        id: ActorId,
        visited: &mut HashSet<ActorId>,
        rec_stack: &mut HashSet<ActorId>,
    ) -> bool {
        visited.insert(id);
        rec_stack.insert(id);
        
        // Check if this actor sends to any other actor
        if let Some(state) = self.actors.get(&id) {
            let state = state.lock().unwrap();
            for msg in &state.mailbox {
                if let ActorMessage::ActorRef(target) = msg {
                    if rec_stack.contains(target) {
                        return true;
                    }
                    if !visited.contains(target) {
                        if self.detect_cycle(*target, visited, rec_stack) {
                            return true;
                        }
                    }
                }
            }
        }
        
        rec_stack.remove(&id);
        false
    }
}

// ============================================================================
// ACTOR MESSAGE QUEUE (for synchronous evaluation)
// ============================================================================

use std::collections::HashSet;

/// A simple message queue for synchronous actor simulation
pub struct MessageQueue {
    queues: HashMap<ActorId, Vec<ActorMessage>>,
}

impl MessageQueue {
    pub fn new() -> Self {
        Self {
            queues: HashMap::new(),
        }
    }
    
    pub fn enqueue(&mut self, target: ActorId, message: ActorMessage) {
        self.queues.entry(target).or_default().push(message);
    }
    
    pub fn dequeue(&mut self, target: ActorId) -> Option<ActorMessage> {
        self.queues.get_mut(&target).and_then(|q| {
            if q.is_empty() { None } else { Some(q.remove(0)) }
        })
    }
    
    pub fn has_messages(&self, target: ActorId) -> bool {
        self.queues.get(&target).map_or(false, |q| !q.is_empty())
    }
}

// ============================================================================
// PUBLIC API
// ============================================================================

/// Create a new actor system
pub fn new_system() -> ActorSystem {
    ActorSystem::new()
}

/// Create a new message queue for synchronous simulation
pub fn new_message_queue() -> MessageQueue {
    MessageQueue::new()
}
