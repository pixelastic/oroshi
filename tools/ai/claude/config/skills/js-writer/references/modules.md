# Modules

- DO NOT use `require`/`module.exports`, always use ES6 `import`/`export`
- DO NOT use `export default`, always named exports
- Include `.js` extension on local imports

## Private Methods (`__`)

Export private methods in a `__` object for test mocking.
Only add a dependency to `__` if a test actually mocks it.
If nothing mocks it, import and call it directly.

```javascript
export let __;

export function publicFn() {
  return __.helper();
}

__ = {
  helper() { /* ... */ },
};
```
