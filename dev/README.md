# Reflection Schemes

exploration of reflective architectures in Scheme

## Exploration Goal

- A flexible toy operating system that can support reflective
  architectures such as JIT and towers of interpreters.

## Design

### `process`

- `thunk`
- `status`

### `os`

- `schedule`: `process -> ()`
- `wait`: `process, process -> ()`
- `step*`: `() -> ()`
