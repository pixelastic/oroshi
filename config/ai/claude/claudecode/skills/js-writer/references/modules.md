# Modules

- DO NOT use `require`/`module.exports`, always use ES6 `import`/`export`
- DO NOT use `export default`, always named exports
- Include `.js` extension on local imports

## Private Methods (`__`)

Export private methods in a `__` object to enable mocking in tests.

```javascript
export let __;

export function publicFn() {
  return __.helper();
}

__ = {
  helper() { /* ... */ },
};
```
