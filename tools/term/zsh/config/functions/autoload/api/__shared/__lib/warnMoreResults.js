/**
 * Tell on stderr that the limit hid some results. Stdout keeps only the
 * results
 */
export function warnMoreResults() {
  console.error('More results exist, raise --limit');
}
