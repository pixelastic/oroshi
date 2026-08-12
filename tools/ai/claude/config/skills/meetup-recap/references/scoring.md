# Scoring

The following are expected outcomes for a meetup.
Each one that went well scores +1.

- [ ] Badging was working correctly
- [ ] Enough seats for everyone
- [ ] Enough food for everyone
- [ ] Enough drinks for everyone
- [ ] Video was working correctly
- [ ] No-show rate was below 50%
- [ ] Started on time
- [ ] We had an Algolia speaker
- [ ] Someone from Algolia helped me organize
- [ ] At least 2 other Algolia employees stayed
- [ ] Talks were linked to what Algolia is doing
- [ ] Talks were interesting
- [ ] We had no troublemakers

**Default assumption:**
if the user's dump says nothing about a criterion, assume it went well (+1).
Only mark 0 if the dump explicitly mentions a problem.

**Compute:** count passed criteria / total criteria → percentage.

**Thresholds:**
- 🔴 below 60%
- 🟢 60–89%
- 🏅 90%+

Display in intro as "Score: 🟢 7/10" (with matching emoji and actual count).
