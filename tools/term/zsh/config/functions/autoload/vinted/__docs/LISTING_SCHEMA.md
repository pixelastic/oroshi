# Vinted listing schema

One listing per JSON file. Explored on the live form (vinted.fr, English UI) on
2026-10-19. The tools target books only: novels, comics and role-playing game
books.

## Fields

| Field         | Label       | Control  | Type     | Required | Test id                                |
| ------------- | ----------- | -------- | -------- | -------- | -------------------------------------- |
| `photos`      | Photos      | file     | string[] | yes      | `add-photos-input` (at least 1 photo)  |
| `title`       | Title       | text     | string   | yes      | `title--input`                         |
| `description` | Description | textarea | string   | yes      | `description--input`                   |
| `category`    | Category    | picker   | string[] | yes      | `catalog-select-dropdown-input`        |
| `isbn`        | ISBN        | text     | string   | no       | `isbn--input`                          |
| `condition`   | Condition   | radio    | enum     | yes      | `category-condition-single-list-input` |
| `price`       | Price       | text     | number   | yes      | `price-input--input` (minimum 1 EUR)   |

- `photos`: paths, resolved relative to the JSON file.
- `category`: the labels to click, from the root to the leaf, as shown in the
  English UI.
- `condition`: one of `New with tags`, `New without tags`, `Very good`, `Good`,
  `Satisfactory`.
- `isbn`: optional. Vinted requires one, so a missing, empty or blank value
  defaults to `0000000000000` (13 zeros).
- `price`: asking price in euros.

## Tracking fields

A listing lives in its own folder, with its photos and a `listing.json`.
`vinted-listing-build` writes the file, and also the tracking fields below. They
are not form fields: the form fill ignores them, and `parseListing` accepts
them.

| Field              | Type           | Values                           |
| ------------------ | -------------- | -------------------------------- |
| `status`           | string         | `draft`, `online` or `sold`      |
| `url`              | string or null | URL of the published item        |
| `postedAt`         | string or null | Publication date, ISO 8601       |
| `soldAt`           | string or null | Sale date, ISO 8601              |
| `isPriceUncertain` | boolean        | `true` when the price is a guess |

- A new listing is a `draft`, with `url`, `postedAt` and `soldAt` set to `null`.
- `isPriceUncertain` defaults to `false`. `vinted-listing-build --uncertain`
  sets it from the price step, and `vinted-listing-recap` lists those listings.
- `vinted-listing-build` fills `language` with `French` and `condition` with
  `Good`.

## Category-dependent fields

The picker is a drill-down: each click opens the next level, until a leaf closes
it. The leaf decides which fields appear below it.

Every book leaf explored has the same fields: Fiction, Non-fiction, and Comics,
manga & graphic novels. Role-playing game books go under Books too, so
`category` is any of these.

Books have no brand, size, colour or material. Other categories (clothes,
Tabletop & miniature gaming) need those fields, and are out of scope.

Once the ISBN is filled, Vinted shows Language, Author and Title on the
published item, so the tools do not need those fields.

Other book leaves (Kids & young adults, Textbooks, Colouring) were not explored.

## Not in the schema

- Parcel size (Small, Medium, Large) is a radio group, with Medium preselected
  and recommended. The tools leave the default alone.
- The form has no field for quantity, shipping price or location.

## Sample

See [listing.sample.json](./listing.sample.json).
