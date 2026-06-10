import { describe, it, expect } from 'vitest'
describe("suite", () => {
  it("passes", () => expect(1).toBe(1))
  it("fails", () => expect(1).toBe(2))
})
