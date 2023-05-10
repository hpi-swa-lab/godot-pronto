# Changelog

## Iteration 1 Week 2

### Multiline Feature
- expressions in the pronto connection editor now support multiline editing
- some expressions and all conditions and arguments require a return statement. A 'return' was previously automatically set in front of the whole statement. Now to allow multiple lines, the return is put directly in the respective text boxes. It can however be deleted and left out, in which case some things may not work, because the return is not being enforced atm.
- text boxes get resized to fit the feature better

### stuff
- older code still expects the return to be set automatically
- to fix this users may have to manually add returns everywhere needed