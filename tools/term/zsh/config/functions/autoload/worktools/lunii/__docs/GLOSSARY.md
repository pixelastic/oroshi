# Lunii

Tools for converting RSS podcast feeds into Lunii story packs.

## Language

**Thumbnail**:
An image displayed on the Lunii screen.
_Avoid_: cover, artwork, picture

**Podcast Thumbnail**:
The **Thumbnail** for the whole podcast, sourced from the RSS feed.
_Avoid_: pack thumbnail, feed image

**Episode Thumbnail**:
The **Thumbnail** for a single **Episode**.
_Avoid_: episode image, episode cover

**Source Episode Thumbnail**:
An **Episode Thumbnail** retrieved from the RSS feed as a JPEG.
_Avoid_: original thumbnail, RSS thumbnail

**Generated Episode Thumbnail**:
An **Episode Thumbnail** created by Claude as SVG then converted to PNG, replacing a generic **Source Episode Thumbnail**.
_Avoid_: AI thumbnail, custom thumbnail

**Episode**:
A single entry in a podcast feed. Called "item" by studio-pack-generator.
_Avoid_: item, entry, track

**Podcast**:
The RSS feed used as input.
_Avoid_: feed, show, channel

**Pack**:
The output directory in Lunii format, produced from a **Podcast**.
_Avoid_: story pack, bundle, archive

## Relationships

- A **Podcast** has one **Podcast Thumbnail** and one or more **Episodes**
- Each **Episode** has one **Source Episode Thumbnail**
- A **Podcast** produces one **Pack**
- **Source Episode Thumbnails** that are identical to each other are replaced by **Generated Episode Thumbnails**
- If `--generate-episode-thumbnails` is passed, all **Source Episode Thumbnails** are replaced by **Generated Episode Thumbnails**

## Flagged ambiguities

- "cover" was used interchangeably with **Episode Thumbnail** — resolved: the canonical term is **Episode Thumbnail**, whether sourced or generated.
- "item" appears in file names (`.item.jpeg`, `.item.png`) because studio-pack-generator uses that convention — the domain term remains **Episode**.

## Example dialogue

> **Dev:** "The **Source Episode Thumbnails** are all the same JPEG — what happens?"
> **Domain expert:** "They get replaced by **Generated Episode Thumbnails** — Claude creates an SVG for each **Episode**, which is then converted to PNG."
>
> **Dev:** "What if I pass `--generate-episode-thumbnails`?"
> **Domain expert:** "Then all **Episodes** get **Generated Episode Thumbnails**, even if the **Source Episode Thumbnails** were unique."
