/**
 * Display a price with two decimals and the euro sign
 * @param {number} price - Price in euros
 * @returns {string} Price like "12.50 €"
 */
export function formatPrice(price) {
  return `${price.toFixed(2)} €`;
}
