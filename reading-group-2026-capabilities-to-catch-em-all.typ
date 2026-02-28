#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.6.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/cetz:0.4.2"
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
  == Goals
  #v(0.75em)
  - Unifying *Mutltitier*, *Choreography*, and *Collective systems* under a single unified framework.
  - *Effects as capabilities* as the unifying abstraction.
  - *Placement types* to integrate the different paradigms.
][

#cetz.canvas({
  import cetz.draw: *
  
  // Paradigm positions (arranged in triangle around center)
  let multitier-pos = (-1.8, -1)
  let choreography-pos = (1.8, -1)
  let collective-pos = (0, 1.2)
  let center-pos = (0, 0)
})

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
  - The agents interact with each other to achieve a *common goal*.
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

= How to unify them?



// #slide[
//   #bibliography("bibliography.bib")
// ]