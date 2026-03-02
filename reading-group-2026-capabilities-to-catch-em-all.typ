#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/cetz:0.4.2": *
#import "utils.typ": *

// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let pdfpc-config = pdfpc.config(
    duration-minutes: 30,
    start-time: datetime(hour: 14, minute: 10, second: 0),
    end-time: datetime(hour: 14, minute: 40, second: 0),
    last-minutes: 5,
    note-font-size: 12,
    disable-markdown: false,
    default-transition: (
      type: "push",
      duration-seconds: 2,
      angle: ltr,
      alignment: "vertical",
      direction: "inward",
    ),
  )

// Theorems configuration by ctheorems
#show: thmrules.with(qed-symbol: $square$)
#let theorem = thmbox("theorem", "Theorem", fill: rgb("#eeffee"))
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))
#let example = thmplain("example", "Example").with(numbering: none)
#let proof = thmproof("proof", "Proof")

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-common(
    // handout: true,
    preamble: pdfpc-config,
    show-bibliography-as-footnote: bibliography(title: none, "bibliography.bib"),
  ),
  config-info(
    title: [The Capabilities to catch 'em all],
    subtitle: [Unify _Multitier_, _Choreography_, and _Aggregate_ via Capabilities],
    author: author_list(
      (
        (first_author("Nicolas Farabegoli"), "nicolas.farabegoli@unibo.it"),
      )
    ),
    date: datetime.today().display("[day] [month repr:long] [year]"),
    institution: [University of Bologna],
    // logo: align(right)[#image("images/disi.svg", width: 55%)],
  ),
)

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(font: "Fira Math")

#set raw(tab-size: 4)
#show raw: set text(size: 1em)
#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: (x: 1em, y: 1em),
  radius: 0.7em,
  width: 100%,
)

#show bibliography: set text(size: 0.75em)
#show footnote.entry: set text(size: 0.75em)

#title-slide()

= LociX

== The capabilities as unifying abstraction

#components.side-by-side[
  === Goals
  #v(0.75em)
  - Unifying *Mutltitier*, *Choreography*, and *Collective systems* under a single unified framework.
  - *Effects as capabilities* as the unifying abstraction.
  - *Placement types* to integrate the different paradigms.
][
  #align(center)[
  #fa-rocket(size: 8em)
  ]
]

= Multiparty Languages

== A global approach

*Multiparty* languages appraches distributed systems from a #bold[global] perspective.

- A *global specification* of the system is given, describing the interactions between all parties.
- The global specification is then *projected* to local specifications for each party.
- The local specifications are then executed by each party.

== Choreography

#components.side-by-side[
  #bold[Choreography] allows to specify a _protocol_ that describes the interactions between parties in a distributed system.
  #v(0.75em)
  - The choreography defines the *parties* in the system.
  - The choreography defines the *messages* exchanged between parties.
  // - The choreography defines the *order* of interactions between parties.
  - The protocol is  *deadlock-free* and *communication-safe* by construction.
][

```rust
let msg_at_alice = op.locally(Alice, |_| {
  println!("Hello from Alice!");
  "Hello from Alice!".to_string()
});
let msg_at_bob = op.comm(
  Alice, Bob, &msg_at_alice
);
op.locally(Bob, |un| {
  let m = un.unwrap(&msg_at_bob);
  println!("Bob received: {}", m);
  m
});
```
]

== Multitier

#components.side-by-side[
  #bold[Multitier] specifies an *architecture* and *peers* of a distributed system, allowing to _move_ code between peers.
  #v(0.75em)
  - The architecture defines the *peers* in the system.
  - The *communications* between peers are #bold[implicit] and conform to the architecture.
  - The distributed logic is implemented by "jumping" between peers.
][
```scala
@multitier object Chat:
  @peer type Server <: {
    type Tie <: Multiple[Client] }
  @peer type Client <: {
    type Tie <: Single[Server] }

  val msg = on[Client] { Evt() }

  val pubMsg = on[Server]:
    msg.asLocalAllSeq.map:
      case (_, m) => m
    
  def main() = on[Client]:
    pubMsg.asLocal.observe:
      case (_, m) =>
        println(s"Received: $m")
```
]

== Collective systems

#components.side-by-side[
  #bold[Collective systems] are distributed systems where the number of parties is not fixed, and parties can join and leave the system dynamically.
  #v(0.75em)
  - The system dynamic: *join*, *leave*, *fail*.
  - The devices interact with each other to achieve a *common goal*.
  - The system is *self-organizing* and *scalable*.
][
```scala
def crowding =
  val dist = distanceTo(S(300))
  val people = // number of people
  // count devices in range
  val count =
    C(dist, people, _ + _)
  // max distance
  val r =
    C(dist, dist, _ max _)
  // density = count / area
  count / (math.Pi * r * r)
```
]

= Why to unify them?

#slide[
  No #bold[silver bullet] for the best approach to design distributed systems.

  Each paradigm has its own #text(fill: color.green)[strengths] and #text(fill: color.red)[weaknesses], and is better suited for *different scenarios*.

  Unifying them under a single framework allows to leverage the strengths of each paradigm, and to choose the *best approach* for each scenario.
]

== City event scenario

=== Smart City case study: CityEvt

The CityEvt application enhances the event experience by providing participants with *recommendations* for nearby points of interest through a smartphone app.

To ensure safety, it monitors *crowd levels* using a decentralized, privacy-preserving algorithm that does not track individual positions.

The system is built on an Edge-Cloud architecture, where different components like #bold[user registration], #bold[crowd monitoring], and #bold[recommendations] are handled by *distinct programming paradigms*.
#line(length: 100%, )
#components.side-by-side[
  === Multitier

  Manages *user registration* and join to the event.
][
  === Choreography

  *Recommends* points of interest to users.
][
  === Collective systems

  Monitors *crowd levels* in the event area.
]

= How to unify them?

#slide[
  #components.side-by-side(columns: (1fr, 2fr))[
    #figure(image("images/oxidizing-scala.png", height: 65%))
  ][
    === Why Scala?

    - *Strong* and *Expressive* type system
    - *Functional* programming paradigm
    - *Contextual abstractions* for capabilities propagation
    - Additional safety features via *Capture* and *Separation* checking.

    The Scala's experimental features allow to control _effects-as-capabilities_ tracking them in the type system, increasing safety and expressiveness of the code.
  ]
]

= Recap: Scala Capture Checking

== Capture checking

```scala
def usingLogFile[T](op: FileOutputStream => T): T =
  val logFile = FileOutputStream("log")
  val result = op(logFile)
  logFile.close()
  result
```

At a first look, this code #bold[seems to be correct], but...

#only("2")[
  === Problematic Code
  ```scala
  val later = usingLogFile { file => (y: Int) => file.write(y) }
  later(10) // crash
  ```

  When `later` is executed it tries to write to a closed file.
]

#pagebreak()

*Capture Checking* enables to spot this kind of problems #bold[statically].

_Capture Checking_ is an experimental feature in Scala 3 that can be enabled with:
```scala
import language.experimental.captureChecking
```
It is possible to re-write the previous code as follows:

```scala
def usingLogFile[T](op: FileOutputStream^ => T): T =
  val logFile = FileOutputStream("log")
  val result = op(logFile)
  logFile.close()
  result
```

The `^` turns the `FileOutputStream` into a *capability*, whose #bold[lifetime] is tracked.

== Rust analogy

This mechanism is similar to the #bold[lifetimes] and #bold[borrowing] mechanism in #fa-rust():

```rust
fn using_log_file<T>(op: impl FnOnce(&mut File) -> T) -> T {
    let mut log_file = File::create("log").unwrap();
    let result = op(&mut log_file);
    // log_file is automatically closed here (Drop trait)
    result
}
```

== Applicability

*Capture checking* has very broad applications:

- Keeps track of #bold[checked exceptions] enabling a clean and fully safe system of exceptions.
- Address the problem of #bold[effect polymorphism] in general.
- Solve the problem of _"what color is you function?"_ (mixing sync and async computations).
- Enables "region-based" allocation (safely).
- Reason about capabilities associated with memory locations.

== Function Types

=== Impure Functions
Functions type like `A => B` now means that the function can capture #underline[arbitrary capabilities].

Those functions are called *impure functions*.

=== Pure Functions

The "thin arrow" `A -> B` means that the function #underline[cannot capture any capability].

Those functions are called *pure functions*.

A capture set to *pure functions* can be added later on `A ->{c,d} B` meaning that the function can capture #emph[only] `c` and `d`, and no others.

This syntax is a short-hand for `(A -> B)^{c,d}`.

== Capability Classifiers

#components.side-by-side(columns: (2fr, 1fr))[
```
              Capability
              /        \
             /          \
            /            \
           /              \
 SharedCapability     ExclusiveCapability
 ----------------            |
        |                    |
        |                 Stateful
        |                    |
        |                    |
     Control              Unscoped
     -------              --------
```
][
/ SharedCapability: can reference other shared capabilities, but not exclusive
/ ExclusiveCapability: is a base trait for capabilities that are checked for anti-aliasing restrictions
]

= Framework

== Architecture Definition

In `LociX` the architecture is defined at the type level, by defining the *peers* of the system and their *ties*.

```scala
type Cloud <: { type Tie <: Multiple[Smartphone] }
type Edge <: { type Tie <: Multiple[Smartphone] & Single[Edge] }
type Smartphone <: { 
  type Tie <: Multiple[Smartphone] & Single[Cloud] & Single[Edge]
}
```

#note-block("Type level architecture validation")[
  Every communication between peers is *statically checked* against the definition
]

== Placement Types

*Placement types* comes with a notion of where a specific value type is located.

Instead of having a single type `T`, we refine it as `T on P` where `P` is a placement type that describes the location of the value.

```scala
val value: Int on Smartphone = /* ... */
```

== Placed computations

In LociX, a placement type is the result of a *placed computation* that is executed at a specific peer.

```scala
val value: Int on Smartphone = on[Smartphone] {
  // computation that produces an Int
  42
}
```

The code above means that the computation `42` is executed at the `Smartphone` peer, and the resulting value is located at the `Smartphone` peer.

#only("2")[
  #warning-block("Everything is a capability in LociX")[
    The `on[P]` construct can only be used if the `Placement` capability is in scope.
  ]
]

== Extract Placement Types

Once we have a value of type `T on P`, we can extract the placement type `P` using the `take` function.

```scala
def placedComputation(v: Int on Smartphone)(using Network, Placement) = 
  on[Smartphone] {
    val placementType = take(v)
    // ...
  }
```

The `take` function can invoked only within a peer scope,
and not at the top level.

#only("2")[
  #warning-block("Architecture validation")[
    A _static error_ is raised if a value placed on a different peer is extracted in a different peer, ensuring that the architecture is respected.
  ]
]

== Multitier in LociX

The *multitier* capability defines the so called "cross-tier" operators,
allowing to move values between (connected) peers.

```scala
trait Multitier extends Multiparty:
  infix type |~>[Id, V]

  def asLocal[L <: TiedSingleWith[R], R <: Peer, V](using
    Network
  )(placement: V on R): V

  def asLocalAll[L <: TiedManyWith[R], R <: Peer, V](using
    n: Network
  )(placement: V on R): n.PeerAddress |~> V
```

#pagebreak()

In the user registration can be implemented as follows:
```scala
type Smartphone <: { type Tie <: Single[Cloud] }
type Cloud <: { type Tie <: Multiple[Smartphone] }

def registration(userId: String)(using Network, Placement, Multitier) =
  val registrationRequest = on[Smartphone] { /* fill form */ }
  val ids = on[Cloud]:
    val request = asLocalAll(registrationRequest)
    request.view.mapValues(registerUser).toMap
  val token = on[Smartphone]:
    val localId = getId(localAddress)
    asLocal(ids)(localId)
  /* use token */
```

== Choreography in LociX

The *choreography* capability defines the communication operators, allowing to exchange values between connected peers.

```scala
trait Choreography extends Multiparty:
  def comm[S <: TiedSingleWith[R], R <: TiedSingleWith[S]](using 
    Network
  )[V](placement: V on S): V on R

  def multicast[S <: TiedManyWith[R], R <: TiedSingleWith[S]](using 
    Network
  )[V](placement: V on S): V on R

  def broadcast[S <: Peer, V](using Network)(placement: V on S): V
```

#pagebreak()

```scala
type Edge <: { type Tie <: Single[Cloud] }
type Cloud <: { type Tie <: Single[Edge] }

def retrievePreference(using Network, Placement, Choreography) = 
  Choreography:
    val smartphonToken = on[Smartphone] { /* get token */ }
    val cloudToken = comm[Edge, Cloud](smartphonToken)
    val isRegistered = on[Cloud]:
      val token = take(cloudToken) /* check if registered */
    val shouldRecommend = comm[Cloud, Edge](isRegistered)
    val recommendation = on[Edge]:
      if (take(shouldRecommend)) { /* provide recommendation */ }
    val recommOnSmartphone = comm[Edge, Smartphone](recommendation)
    on[Smartphone]:
      val rec = take(recommOnSmartphone)
      /* use recommendation */
```

== Collective in LociX

In LociX, the *collective* capability is implemented via _aggregate computing_, following the #bold[field calculus] model.

```scala
trait Collective extends Multiparty:
  def rep[V](initial: V)(evolution: V -> V)(using VM): V
  def nbr[V](value: V)(using VM): Field[V]
  def branch[V](cond: Boolean)(th: -> V)(el: -> V)(using VM): V
  def mux[V](condition: Boolean)(th: V)(el: V)(using VM): V
```

== Execution model

To deal with the *round-based*  execution model of aggregate computing, LociX introduces the notion of *round scopes*.

```scala
def apply[P <: TiedManyWith[P]](using
    n: Network,
    p: Placement,
    c: Collective,
    ec: ExecutionContext
)[V](round: FiniteDuration)(program: VM^ ?->{c} V): Signal[V] on P
```

= Safety Features

== Everything is a capability

In LociX, every value is a capability, and the type system tracks the capabilities associated with each value.

```scala
trait Multiparty extends SharedCapability
```

A `SharedCapability` has the following properties:

/ Capture checking: tracks the lifetime of the capability, ensuring that the intended scoping rules are respected
/ Separation checking: ensures that a shared capability do not reference any `ExclusiveCapability` in its capture set

== Enforce coherent paradigm usage

LociX integrates *choreography*, *multitier*, and *collective*.

We want to ensure each paradigm is used in a #bold[delimited] and #bold[consistent] way.

In LociX we enforce that specific paradigm operations are used in a proper scope, avoiding the risk of mixing different paradigms in an incoherent way.

```scala
object Multitier:
  sealed trait MultitierScope extends Erased

  def asLocal[L <: TiedSingleWith[R], R <: Peer, V, SC](using
    Multitier, Network, PeerScope[L], Scope[SC], SC =:= MultitierScope
  )(value: V on R): V

  def apply[A](using Multitier)(multitier: Scope[MultitierScope] ?=> A): A
  /* Other omitted for brevity */
```

Consider this inconsistent code usage:

```scala
def foo(using Network, Multitier, Choreography) = Multitier:
  val x = on[Peer1] { /* ... */ }
  val y = on[Peer2] { /* ... */ }
  val z = Choreography.comm[Peer1, Peer2](x) // error
  on[Peer2] {
    val v = asLocal(x)
  }
```

Such mixing of multitier and choreography is conceptually wrong,
and we prevent it at #bold[compile time].

== Avoid Leaking of capabilities

```scala
type Alice <: { type Tie <: Single[Bob] }
type Bob <: { type Tie <: Single[Alice] }

def choreography(using Choreography, Network): Unit =
  val valuOnAlice: String on Alice = on[Alice] { "Hello from Alice!" }
  val funAtAlice: (() => String) on Alice = on[Alice] {
    () => valuOnAlice.take
  }
  val msgAtBob: (() => String) on Bob = comm[Alice, Bob](funAtAlice)
  on[Bob] {
    val f: () => String = msgAtBob.take
    f()
  }
```

With _capture checking_ we ensure the referenced capability in `Alice` do not leak in the `Bob` context, preventing #bold[runtime errors].

== Prevent Placement nesting

```scala
trait PlacementType extends Mutable:
  update def on[P <: Peer, V](using Network)(
      body: PeerScope[P] ?=> V
  ): V on P
```

The `Mutable` trait extends `ExclusiveCapability` meaning that the _separation checking_ ensures the non-aliased access to the `PlacementType`.

In other words, the placement type should occur #bold[at most once] in the capture set of any shared capability.

#pagebreak()

This modelling prevents such scenarios:

```scala
type Placement = PlacementType^

def foo(using Network, Placement) =
  on[Peer1] { // separation failure here
    val x = on[Peer2] { /* ... */ }
    val c = comm[Peer2, Peer1](x) // error
  }
```
With the error:
```
Separation failure: argument of type
(x$2 : io.github.nicolasfara.locix.placement.PlacementType^) to method
on: [P <: io.github.nicolasfara.locix.peers.Peers.Peer]
```

= Wrap-up

#slide[
  === LociX

  - A framework for unifying *multitier*, *choreography*, and *collective* programming paradigms.
  - Based on the notion of *capabilities* and *placement types*.
  - Provides safety features via *capture* and *separation* checking.
  - At the intersection of _rust_ and _koka_ mixing the ergonomicity of algebraic effects, with the safety of Rust's ownership system.
]


// #slide[
//   #bibliography("bibliography.bib")
// ]