# App: Automatic Data Migration

Create structures that can be automatically migrated according to some schemes.

## Exploration Goal

- Do we need reflection in the language for a use case that looks a bit reflective at the system level?

- Non-goal: match or be inspired by current solutions to data migration.

## Spec

"Stamped" structures may have a special field stamp.

There is a database for how to migrate (ie: convert, transform) from a structure with one stamp to a structure with another.
Migration can be direct or indirect (transitive), with specific rules (TBD) for precedence.

A user of a stamped structure may require that specific stamps be used.
Then the structure is migated as necessary.

## Design Alternatives

Migrations could be integrated at the type level. In which case there would need to be reflection on types? Could be interesting to try in Scala? Or Idris/Lean?

Maybe reflection here would consist in seamlessly requiring and migrating instead of using an explicit requirement?

## Design

- Use Scheme structs for our stamped structs.
- Use an explicit requirement
```
(let ((o (require-stamp o '(stamp1 stamp2))))
    ...)
```
