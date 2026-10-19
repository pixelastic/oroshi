# Vinted listing schema

One listing per JSON file. Explored on the live form (vinted.fr, English UI) on 2026-10-19. The tools target books only: novels, comics and role-playing game books.

## Fields

| Field         | Label       | Control  | Type     | Required | Test id                                  |
|---------------|-------------|----------|----------|----------|------------------------------------------|
| `photos`      | Photos      | file     | string[] | yes      | `add-photos-input` (at least 1 photo)    |
| `title`       | Title       | text     | string   | yes      | `title--input`                           |
| `description` | Description | textarea | string   | yes      | `description--input`                     |
| `category`    | Category    | picker   | string[] | yes      | `catalog-select-dropdown-input`          |
| `isbn`        | ISBN        | text     | string   | yes      | `isbn--input`                            |
| `condition`   | Condition   | radio    | enum     | yes      | `category-condition-single-list-input`   |
| `price`       | Price       | text     | number   | yes      | `price-input--input` (minimum 1 EUR)     |

- `photos`: paths, resolved relative to the JSON file.
- `category`: the labels to click, from the root to the leaf, as shown in the English UI.
- `condition`: one of `New with tags`, `New without tags`, `Very good`, `Good`, `Satisfactory`.
- `price`: asking price in euros.

## Category-dependent fields

The picker is a drill-down: each click opens the next level, until a leaf closes it. The leaf decides which fields appear below it.

Every book leaf explored has the same fields: Fiction, Non-fiction, and Comics, manga & graphic novels. Role-playing game books go under Books too, so `category` is any of these.

Books have no brand, size, colour or material. Other categories (clothes, Tabletop & miniature gaming) need those fields, and are out of scope.

Once the ISBN is filled, Vinted shows Language, Author and Title on the published item, so the tools do not need those fields.

Other book leaves (Kids & young adults, Textbooks, Colouring) were not explored.

## Not in the schema

- Parcel size (Small, Medium, Large) is a radio group, with Medium preselected and recommended. The tools leave the default alone.
- The form has no field for quantity, shipping price or location.

## Sample

See [listing.sample.json](./listing.sample.json).
